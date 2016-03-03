package checkstyle.checks.block;

import checkstyle.Checker.LinePos;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("EmptyBlock")
@desc("Checks for empty blocks")
class EmptyBlockCheck extends Check {

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

	// allow empty blocks but enforce "{}" notation
	public static inline var EMPTY:String = "empty";
	// empty blocks must contain something apart from whitespace (comment or statement)
	public static inline var TEXT:String = "text";
	// all blocks must contain at least one statement
	public static inline var STATEMENT:String = "stmt";

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
			OBJECT_DECL,
			FUNCTION,
			FOR,
			IF,
			WHILE,
			SWITCH,
			TRY,
			CATCH
		];
		option = EMPTY;
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
			if (filterParentToken(brOpen.parent)) continue;
			switch (option) {
				case TEXT:
					checkForText(brOpen);
				case STATEMENT:
					checkForStatement(brOpen);
				case EMPTY:
					checkForEmpty(brOpen);
				default:
					checkForText(brOpen);
			}
		}
	}

	function filterParentToken(token:TokenTree):Bool {
		if (token == null) return false;
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

	function checkForText(brOpen:TokenTree) {
		if (brOpen.childs.length == 1) {
			logPos('Empty block should contain a comment or a statement', brOpen.pos, Reflect.field(SeverityLevel, severity));
			return;
		}
	}

	function checkForStatement(brOpen:TokenTree) {
		if (brOpen.childs.length == 1) {
			logPos('Empty block should contain a statement', brOpen.pos, Reflect.field(SeverityLevel, severity));
			return;
		}
		var onlyComments:Bool = true;
		for (child in brOpen.childs) {
			switch (child.tok) {
				case Comment(_), CommentLine(_):
				case BrClose:
				default:
					onlyComments = false;
					break;
			}
		}
		if (onlyComments) {
			logPos('Block should contain a statement', brOpen.pos, Reflect.field(SeverityLevel, severity));
		}
	}

	function checkForEmpty(brOpen:TokenTree) {
		if (brOpen.childs.length > 1) {
			return;
		}
		var brClose:TokenTree = brOpen.childs[0];
		if (brOpen.pos.max != brClose.pos.min) {
			logPos("Empty block should be written as {}", brOpen.pos, Reflect.field(SeverityLevel, severity));
		}
	}
}