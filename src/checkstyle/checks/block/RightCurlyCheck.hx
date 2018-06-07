package checkstyle.checks.block;

/**
	Checks the placement of right curly braces ("}") for code blocks. The policy to verify is specified using the property "option".
 **/
@name("RightCurly")
@desc("Checks the placement of right curly braces (`}`) for code blocks. The policy to verify is specified using the property `option`.")
class RightCurlyCheck extends Check {

	/**
	    matches only right curlys specified in tokens list:
		- CLASS_DEF = class definition "class Test {}"
		- ENUM_DEF = enum definition "enum Test {}"
		- ABSTRACT_DEF = abstract definition "abstract Test {}"
		- TYPEDEF_DEF = typdef definition "typedef Test = {}"
		- INTERFACE_DEF = interface definition "interface Test {}"
		- OBJECT_DECL = object declaration "{ x: 0, y: 0, z: 0}"
		- FUNCTION = function body "funnction test () {}"
		- FOR = for body "for (i in 0..10) {}"
		- IF = if / else body "if (test) {} else {}"
		- WHILE = while body "while (test) {}"
		- SWITCH = switch / case body "switch (test) { case: {} default: {} }"
		- TRY = try body "try {}"
		- CATCH = catch body "catch (e:Dynamic) {}"
		- REIFICATION = macro reification "$i{}"
		- ARRAY_COMPREHENSION = array comprehension "[for (i in 0...10) {i * 2}]"
	 **/
	public var tokens:Array<RightCurlyCheckToken>;

	/**
	    placement of right curly
		- same = right curly must be alone on a new line, except for "} else" and "} catch"
		- alone = alone on a new line
		- aloneorsingle = right curly can occur on same line as left curly or must be alone on a new line
	 **/
	public var option:RightCurlyCheckOption;

	public function new() {
		super(TOKEN);
		tokens = [
			CLASS_DEF,
			ENUM_DEF,
			ABSTRACT_DEF,
			TYPEDEF_DEF,
			INTERFACE_DEF,
			OBJECT_DECL,
			FUNCTION,
			FOR,
			IF,
			WHILE,
			SWITCH,
			TRY,
			CATCH
		];
		option = ALONE_OR_SINGLELINE;
	}

	function hasToken(token:RightCurlyCheckToken):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allBrClose:Array<TokenTree> = root.filter([BrClose], ALL);

		for (brClose in allBrClose) {
			if (isPosSuppressed(brClose.pos)) continue;
			var brOpen:TokenTree = brClose.parent;
			if ((brOpen == null) || (brOpen.pos == null)) continue;
			if (filterParentToken(brOpen.parent)) continue;
			check(brClose, isSingleLine(brOpen.pos.min, brClose.pos.max));
		}
	}

	function filterParentToken(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return false;
		switch (token.tok) {
			case Kwd(KwdClass):
				return !hasToken(CLASS_DEF);
			case Kwd(KwdInterface):
				return !hasToken(INTERFACE_DEF);
			case Kwd(KwdAbstract):
				return !hasToken(ABSTRACT_DEF);
			case Kwd(KwdTypedef):
				return !hasToken(TYPEDEF_DEF);
			case Kwd(KwdEnum):
				return !hasToken(ENUM_DEF);
			case Kwd(KwdFunction):
				return !hasToken(FUNCTION);
			case Kwd(KwdIf), Kwd(KwdElse):
				return !hasToken(IF);
			case Kwd(KwdFor):
				if (isArrayComprehension(token.parent)) {
					return !hasToken(ARRAY_COMPREHENSION);
				}
				return !hasToken(FOR);
			case Kwd(KwdWhile):
				return !hasToken(WHILE);
			case Kwd(KwdTry):
				return !hasToken(TRY);
			case Kwd(KwdCatch):
				return !hasToken(CATCH);
			case Kwd(KwdSwitch), Kwd(KwdCase), Kwd(KwdDefault):
				return !hasToken(SWITCH);
			case POpen, BkOpen, BrOpen, Kwd(KwdReturn):
				return !hasToken(OBJECT_DECL);
			case Dollar(_):
				return !hasToken(REIFICATION);
			case Binop(OpAssign):
				// could be OBJECT_DECL or TYPEDEF_DEF
				if ((token.parent != null) && (token.parent.parent != null)) {
					switch (token.parent.parent.tok) {
						case Kwd(KwdTypedef):
							return !hasToken(TYPEDEF_DEF);
						default:
					}
				}
				return !hasToken(OBJECT_DECL);
			default:
				return filterParentToken(token.parent);
		}
	}

	function isArrayComprehension(token:TokenTree):Bool {
		return switch (token.tok) {
			case BkOpen: true;
			case Kwd(KwdFunction): false;
			case Kwd(KwdVar): false;
			default: isArrayComprehension(token.parent);
		}
	}

	function check(token:TokenTree, singleLine:Bool) {
		var lineNum:Int = checker.getLinePos(token.pos.min).line;
		var line:String = checker.lines[lineNum];
		checkRightCurly(line, singleLine, token.pos);
	}

	function isSingleLine(start:Int, end:Int):Bool {
		var startLine:Int = checker.getLinePos(start).line;
		if (end >= checker.file.content.length) end = checker.file.content.length - 1;
		var endLine:Int = checker.getLinePos(end).line;
		return startLine == endLine;
	}

	function checkRightCurly(line:String, singleLine:Bool, pos:Position) {
		try {
			var curlyPos:Position = {file: pos.file, min: pos.min, max: pos.max};
			var eof:Bool = false;
			if (curlyPos.max >= checker.file.content.length) {
				curlyPos.max = checker.file.content.length - 1;
				eof = true;
			}
			var linePos:LinePos = checker.getLinePos(curlyPos.max);
			var afterCurly:String = "";
			if (!eof) {
				var afterLine:Bytes = Bytes.ofString(checker.lines[linePos.line]);
				if (linePos.ofs < afterLine.length) afterCurly = afterLine.sub(linePos.ofs, afterLine.length - linePos.ofs).toString();
			}
			// only else and catch allowed on same line after a right curly
			var sameRegex = ~/^\s*(else|catch)/;
			var needsSameOption:Bool = sameRegex.match(afterCurly);
			var shouldHaveSameOption:Bool = false;
			if (checker.lines.length > linePos.line + 1) {
				var nextLine:String = checker.lines[linePos.line + 1];
				shouldHaveSameOption = sameRegex.match(nextLine);
			}
			// adjust to show correct line number in log message
			curlyPos.min = curlyPos.max;

			logErrorIf(singleLine && (option != ALONE_OR_SINGLELINE), "Right curly should not be on same line as left curly", curlyPos);
			if (singleLine) return;

			var curlyAlone:Bool = ~/^\s*\}[\)\],;\s]*(|\/\/.*)$/.match(line);
			logErrorIf(!curlyAlone && (option == ALONE_OR_SINGLELINE || option == ALONE), "Right curly should be alone on a new line", curlyPos);
			logErrorIf(curlyAlone && needsSameOption, "Right curly should be alone on a new line", curlyPos);
			logErrorIf(needsSameOption && (option != SAME), "Right curly must not be on same line as following block", curlyPos);
			logErrorIf(shouldHaveSameOption && (option == SAME), 'Right curly should be on same line as following block (e.g. "} else" or "} catch")', curlyPos);
		}
		catch (e:String) {
			// one of the error messages fired -> do nothing
		}
	}

	function logErrorIf(condition:Bool, msg:String, pos:Position) {
		if (condition) {
			logPos(msg, pos);
			throw "exit";
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [{
				propertyName: "tokens",
				value: [
					CLASS_DEF,
					ENUM_DEF,
					ABSTRACT_DEF,
					TYPEDEF_DEF,
					INTERFACE_DEF,
					OBJECT_DECL,
					FUNCTION,
					FOR,
					WHILE,
					SWITCH,
					TRY,
					CATCH
				]
			}],
			properties: [{
				propertyName: "option",
				values: [ALONE_OR_SINGLELINE, ALONE, SAME]
			}]
		},
		{
			fixed: [{
				propertyName: "tokens",
				value: [
					IF,
				]
			}],
			properties: [{
				propertyName: "option",
				values: [ALONE_OR_SINGLELINE, ALONE, SAME]
			}]
		},
		{
			fixed: [{
				propertyName: "tokens",
				value: [
					OBJECT_DECL
				]
			}],
			properties: [{
				propertyName: "option",
				values: [ALONE_OR_SINGLELINE, ALONE, SAME]
			}]
		}];
	}
}

@:enum
abstract RightCurlyCheckToken(String) {
	var CLASS_DEF = "CLASS_DEF";
	var ENUM_DEF = "ENUM_DEF";
	var ABSTRACT_DEF = "ABSTRACT_DEF";
	var TYPEDEF_DEF = "TYPEDEF_DEF";
	var INTERFACE_DEF = "INTERFACE_DEF";

	var OBJECT_DECL = "OBJECT_DECL";
	var FUNCTION = "FUNCTION";
	var FOR = "FOR";
	var IF = "IF";
	var WHILE = "WHILE";
	var SWITCH = "SWITCH";
	var TRY = "TRY";
	var CATCH = "CATCH";
	var REIFICATION = "REIFICATION";
	var ARRAY_COMPREHENSION = "ARRAY_COMPREHENSION";
}

@:enum
abstract RightCurlyCheckOption(String) {
	var SAME = "same";
	var ALONE = "alone";
	var ALONE_OR_SINGLELINE = "aloneorsingle";
}