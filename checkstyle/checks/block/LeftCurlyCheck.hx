package checkstyle.checks.block;

import checkstyle.Checker.LinePos;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("LeftCurly")
@desc("Checks for placement of left curly braces")
class LeftCurlyCheck extends Check {

	public static inline var CLASS_DEF:String = "CLASS_DEF";
	public static inline var ENUM_DEF:String = "ENUM_DEF";
	public static inline var ABSTRACT_DEF:String = "ABSTRACT_DEF";
	public static inline var TYPEDEF_DEF:String = "TYPEDEF_DEF";
	public static inline var INTERFACE_DEF:String = "INTERFACE_DEF";

	public static inline var OBJECT_DECL:String = "OBJECT_DECL";
	public static inline var FUNCTION:String = "FUNCTION";
	public static inline var FOR:String = "FOR";
	public static inline var IF:String = "IF";
	public static inline var WHILE:String = "WHILE";
	public static inline var SWITCH:String = "SWITCH";
	public static inline var TRY:String = "TRY";
	public static inline var CATCH:String = "CATCH";
	public static inline var REIFICATION:String = "REIFICATION";

	public static inline var EOL:String = "eol";
	public static inline var NL:String = "nl";
	public static inline var NLOW:String = "nlow";

	public var tokens:Array<String>;
	public var option:String;

	public function new() {
		super();
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
	}

	function hasToken(token:String):Bool {
		if (tokens.length == 0) return true;
		if (tokens.indexOf(token) > -1) return true;
		return false;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allBrOpen:Array<TokenTree> = root.filter([BrOpen], ALL);

		for (brOpen in allBrOpen) {
			if (isPosSuppressed(brOpen.pos)) continue;
			var parent:ParentToken = findParentToken(brOpen.parent);
			if (!parent.hasToken) continue;
			check(brOpen, isParentWrapped(parent.token, brOpen));
		}
	}

	/**
	 * find effective parent token and check against configured tokens
	 */
	@SuppressWarnings("checkstyle:CyclomaticComplexity")
	function findParentToken(token:TokenTree):ParentToken {
		if (token == null) return {token:token, hasToken: false};
		switch(token.tok) {
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
				return {token: token, hasToken: hasToken(FOR)};
			case Kwd(KwdWhile):
				return {token: token, hasToken: hasToken(WHILE)};
			case Kwd(KwdTry):
				return {token: token, hasToken: hasToken(TRY)};
			case Kwd(KwdCatch):
				return {token: token, hasToken: hasToken(CATCH)};
			case Kwd(KwdSwitch), Kwd(KwdCase), Kwd(KwdDefault):
				return {token: token, hasToken: hasToken(SWITCH)};
			case POpen, BkOpen, BrOpen, Kwd(KwdReturn):
				return {token: token, hasToken: hasToken(OBJECT_DECL)};
			case Dollar(_):
				return {token: token, hasToken: hasToken(REIFICATION)};
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
				return findParentToken(token.parent);
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

	function check(token:TokenTree, wrapped:Bool) {
		var lineNum:Int = checker.getLinePos(token.pos.min).line;
		var line:String = checker.lines[lineNum];
		checkLeftCurly(line, wrapped, token.pos);
	}

	function checkLeftCurly(line:String, wrapped:Bool = false, pos:Position) {
		var lineLength:Int = line.length;

		// must have at least one non whitespace character before curly
		// and only whitespace, }, /* + comment or // + comment after curly
		var curlyAtEOL:Bool = ~/^\s*\S.*\{\}?\s*(|\/\*.*|\/\/.*)$/.match(line);
		// must have only whitespace before curly
		var curlyOnNL:Bool = ~/^\s*\{\}?/.match(line);

		try {
			if (curlyAtEOL) {
				logErrorIf ((option == NL), 'Left curly should be on new line (only whitespace before curly)', pos);
				logErrorIf ((option == NLOW) && wrapped, 'Left curly should be on new line (previous expression is split over muliple lines)', pos);
				logErrorIf ((option != EOL) && (option != NLOW), 'Left curly unknown option ${option}', pos);
				return;
			}
			logErrorIf ((option == EOL), 'Left curly should be at EOL (only linebreak or comment after curly)', pos);
			logErrorIf ((!curlyOnNL), 'Left curly should be on new line (only whitespace before curly)', pos);
			logErrorIf ((option == NLOW) && !wrapped, 'Left curly should be at EOL (previous expression is not split over muliple lines)', pos);
			logErrorIf ((option != NL) && (option != NLOW), 'Left curly unknown option ${option}', pos);
		}
		catch (e:String) {
			// one of the error messages fired -> do nothing
		}
	}

	function logErrorIf(condition:Bool, msg:String, pos:Position) {
		if (condition) {
			logPos(msg, pos, Reflect.field(SeverityLevel, severity));
			throw "exit";
		}
	}
}

typedef ParentToken = {
	token:TokenTree,
	hasToken:Bool
}