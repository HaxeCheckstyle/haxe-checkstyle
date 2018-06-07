package checkstyle.checks.block;

/**
    Checks for the placement of left curly braces ("{") for code blocks. The policy to verify is specified using the property "option".
 **/
@name("LeftCurly")
@desc("Checks for the placement of left curly braces (`{`) for code blocks. The policy to verify is specified using the property `option`.")
class LeftCurlyCheck extends Check {

	/**
	    matches only left curlys specified in tokens list:
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
	public var tokens:Array<LeftCurlyCheckToken>;

	/**
	    placement of left curly
		- eol = should occur at end of line
	    - nl = should occur on a new line
		- nlow = should occur at end of line unless in wrapped code, then it should occur on a new line
	 */
	public var option:LeftCurlyCheckOption;

	/**
	    allow single line blocks
	 **/
	public var ignoreEmptySingleline:Bool;

	public function new() {
		super(TOKEN);
		tokens = [
			CLASS_DEF,
			ENUM_DEF,
			ABSTRACT_DEF,
			TYPEDEF_DEF,
			INTERFACE_DEF,
				//OBJECT_DECL, // => allow inline object declarations
			FUNCTION,
			FOR,
			IF,
			WHILE,
			SWITCH,
			TRY,
			CATCH
		];
		option = EOL;
		ignoreEmptySingleline = true;
	}

	function hasToken(token:LeftCurlyCheckToken):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allBrOpen:Array<TokenTree> = root.filter([BrOpen], ALL);

		for (brOpen in allBrOpen) {
			if (isPosSuppressed(brOpen.pos)) continue;
			if (ignoreEmptySingleline && isSingleLine(brOpen)) continue;
			var parent:ParentToken = findParentToken(brOpen.parent);
			if (!parent.hasToken) continue;
			check(brOpen, isParentWrapped(parent.token, brOpen));
		}
	}

	function isSingleLine(brOpen:TokenTree):Bool {
		var brClose:TokenTree = brOpen.getLastChild();
		return (brClose != null && brOpen.pos.max == brClose.pos.min);
	}

	/**
	 * find effective parent token and check against configured tokens
	 */
	function findParentToken(token:TokenTree):ParentToken {
		if ((token == null) || (token.tok == null)) return {token:token, hasToken: false};
		switch (token.tok) {
			case Kwd(KwdClass):
				return {token: token, hasToken: hasToken(CLASS_DEF)};
			case Kwd(KwdInterface):
				return {token: token, hasToken: hasToken(INTERFACE_DEF)};
			case Kwd(KwdAbstract):
				return {token: token, hasToken: hasToken(ABSTRACT_DEF)};
			case Kwd(KwdTypedef):
				return {token: token, hasToken: hasToken(TYPEDEF_DEF)};
			case Kwd(KwdEnum):
				return {token: token, hasToken: hasToken(ENUM_DEF)};
			case Kwd(KwdFunction):
				return {token: token, hasToken: hasToken(FUNCTION)};
			case Kwd(KwdIf), Kwd(KwdElse):
				return {token: token, hasToken: hasToken(IF)};
			case Kwd(KwdFor):
				if (isArrayComprehension(token.parent)) {
					return {token: token, hasToken: hasToken(ARRAY_COMPREHENSION)};
				}
				return {token: token, hasToken: hasToken(FOR)};
			case Kwd(KwdWhile):
				return {token: token, hasToken: hasToken(WHILE)};
			case Kwd(KwdTry):
				return {token: token, hasToken: hasToken(TRY)};
			case Kwd(KwdCatch):
				return {token: token, hasToken: hasToken(CATCH)};
			case Kwd(KwdSwitch), Kwd(KwdDefault):
				return {token: token, hasToken: hasToken(SWITCH)};
			case Kwd(KwdCase):
				return {token: token, hasToken: hasToken(OBJECT_DECL)};
			case DblDot:
				return findParentTokenDblDot(token.parent);
			case POpen, BkOpen, BrOpen, Kwd(KwdReturn):
				return {token: token, hasToken: hasToken(OBJECT_DECL)};
			case Dollar(_):
				return {token: token, hasToken: hasToken(REIFICATION)};
			case Binop(OpAssign):
				// could be OBJECT_DECL or TYPEDEF_DEF
				if ((token.parent != null) && (token.parent.parent != null)) {
					if (token.parent.parent.tok.match(Kwd(KwdTypedef))) {
						return {token: token, hasToken: hasToken(TYPEDEF_DEF)};
					}
				}
				return {token: token, hasToken: hasToken(OBJECT_DECL)};
			default:
				return findParentToken(token.parent);
		}
	}

	function findParentTokenDblDot(token:TokenTree):ParentToken {
		if ((token == null) || (token.tok == null)) return {token:token, hasToken: false};
		switch (token.tok) {
			case Kwd(KwdCase), Kwd(KwdDefault):
				return {token: token, hasToken: hasToken(SWITCH)};
			case POpen, BkOpen, BrOpen, Kwd(KwdReturn):
				return {token: token, hasToken: hasToken(OBJECT_DECL)};
			case Binop(OpAssign):
				// could be OBJECT_DECL or TYPEDEF_DEF
				if ((token.parent != null) && (token.parent.parent != null)) {
					switch (token.parent.parent.tok) {
						case Kwd(KwdTypedef):
							return {token: token, hasToken: hasToken(TYPEDEF_DEF)};
						default:
					}
				}
				return {token: token, hasToken: hasToken(OBJECT_DECL)};
			default:
				return findParentTokenDblDot(token.parent);
		}
	}

	function isParentWrapped(parent:TokenTree, brOpen:TokenTree):Bool {
		var lineNumStart:Int = checker.getLinePos(parent.pos.min).line;
		var previous:TokenTree = brOpen.previousSibling;
		while (previous != null) {
			switch (previous.tok) {
				case Comment(_), CommentLine(_), At:
					previous = previous.previousSibling;
				default:
					break;
			}
		}
		var lineNumEnd:Int;
		if (previous == null) {
			lineNumEnd = checker.getLinePos(brOpen.parent.pos.max).line;
		}
		else {
			lineNumEnd = checker.getLinePos(previous.getPos().max).line;
		}
		return (lineNumStart != lineNumEnd);
	}

	function isArrayComprehension(token:TokenTree):Bool {
		return switch (token.tok) {
			case BkOpen: true;
			case Kwd(KwdFunction): false;
			case Kwd(KwdVar): false;
			default: isArrayComprehension(token.parent);
		}
	}

	function check(token:TokenTree, wrapped:Bool) {
		var lineNum:Int = checker.getLinePos(token.pos.min).line;
		var line:String = checker.lines[lineNum];
		checkLeftCurly(line, wrapped, token.pos);
	}

	function checkLeftCurly(line:String, wrapped:Bool = false, pos:Position) {
		// must have at least one non whitespace character before curly
		// and only whitespace, /* + comment or // + comment after curly
		var curlyAtEOL:Bool = ~/^\s*\S.*\{\s*(|\/\*.*|\/\/.*)$/.match(line);
		// must have only whitespace before curly
		var curlyOnNL:Bool = ~/^\s*\{/.match(line);

		try {
			if (curlyAtEOL) {
				logErrorIf((option == NL), "Left curly should be on new line (only whitespace before curly)", pos);
				logErrorIf((option == NLOW) && wrapped, "Left curly should be on new line (previous expression is split over multiple lines)", pos);
				logErrorIf((option != EOL) && (option != NLOW), "Left curly unknown option ${option}", pos);
				return;
			}
			logErrorIf((option == EOL), "Left curly should be at EOL (only line break or comment after curly)", pos);
			logErrorIf((!curlyOnNL), "Left curly should be on new line (only whitespace before curly)", pos);
			logErrorIf((option == NLOW) && !wrapped, "Left curly should be at EOL (previous expression is not split over multiple lines)", pos);
			logErrorIf((option != NL) && (option != NLOW), "Left curly unknown option ${option}", pos);
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
					INTERFACE_DEF,
					FUNCTION,
					FOR,
					IF,
					WHILE,
					SWITCH,
					TRY,
					CATCH
				]
			}],
			properties: [{
				propertyName: "option",
				values: [EOL, NLOW, NL]
			},
			{
				propertyName: "ignoreEmptySingleline",
				values: [true, false]
			}]
		},
		{
			fixed: [{
				propertyName: "tokens",
				value: [
					TYPEDEF_DEF,
				]
			}],
			properties: [{
				propertyName: "option",
				values: [EOL, NLOW, NL]
			},
			{
				propertyName: "ignoreEmptySingleline",
				values: [true, false]
			}]
		}];
	}
}

typedef ParentToken = {
	var token:TokenTree;
	var hasToken:Bool;
}

@:enum
abstract LeftCurlyCheckToken(String) {
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
abstract LeftCurlyCheckOption(String) {
	var EOL = "eol";
	var NL = "nl";
	var NLOW = "nlow";
}