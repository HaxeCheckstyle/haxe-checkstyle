package checkstyle.checks.block;

/**
	Checks for empty blocks. The policy to verify is specified using the property "option".
**/
@name("EmptyBlock")
@desc("Checks for empty blocks. The policy to verify is specified using the property `option`.")
class EmptyBlockCheck extends Check {
	/**
		matches only blocks specified in tokens list:
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
	**/
	public var tokens:Array<EmptyBlockCheckToken>;

	/**
		for all empty blocks matched by tokens
		- empty = allow empty blocks but enforce "{}" notation
		- text = must contain something apart from whitespace (comment or statement)
		- stmt = must contain at least one statement (that is not a comment)
	**/
	public var option:EmptyBlockCheckOption;

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
		option = EMPTY;
	}

	function hasToken(token:EmptyBlockCheckToken):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allBrOpen:Array<TokenTree> = root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case BrOpen:
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

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
		if ((token == null) || (token.tok == Root)) return false;
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
			case Dollar(_):
				return !hasToken(REIFICATION);
			case Binop(OpAssign):
				// could be OBJECT_DECL or TYPEDEF_DEF
				if ((token.parent != null) && (token.parent.parent != null)) {
					switch (token.parent.parent.tok) {
						case Kwd(KwdTypedef): return !hasToken(TYPEDEF_DEF);
						default:
					}
				}
				return !hasToken(OBJECT_DECL);
			default:
				return filterParentToken(token.parent);
		}
	}

	function checkForText(brOpen:TokenTree) {
		if (brOpen.children.length == 1) {
			logPos("Empty block should contain a comment or a statement", brOpen.getPos());
			return;
		}
		var lastChild:TokenTree = brOpen.getLastChild();
		if ((brOpen.children.length == 2) && lastChild.matches(Semicolon)) {
			logPos("Empty block should contain a comment or a statement", brOpen.getPos());
			return;
		}
	}

	function checkForStatement(brOpen:TokenTree) {
		if (brOpen.children.length == 1) {
			logPos("Empty block should contain a statement", brOpen.getPos());
			return;
		}
		var lastChild:TokenTree = brOpen.getLastChild();
		if ((brOpen.children.length == 2) && lastChild.matches(Semicolon)) {
			logPos("Empty block should contain a statement", brOpen.getPos());
			return;
		}
		var onlyComments:Bool = true;
		for (child in brOpen.children) {
			switch (child.tok) {
				case Comment(_), CommentLine(_):
				case BrClose:
					break;
				default:
					onlyComments = false;
					break;
			}
		}
		if (onlyComments) logPos("Block should contain a statement", brOpen.getPos());
	}

	function checkForEmpty(brOpen:TokenTree) {
		if (brOpen.children == null) return;
		if (brOpen.children.length <= 0) return;

		var lastChild:TokenTree = brOpen.getLastChild();
		if (brOpen.access().lastChild().matches(Semicolon).exists()) {
			if (brOpen.children.length > 2) return;
		}
		else {
			if (brOpen.children.length > 1) return;
		}

		var brClose:TokenTree = brOpen.access().firstChild().matches(BrClose).token;
		if (brClose == null) return;
		if (brOpen.pos.max != brClose.pos.min) logPos('Empty block should be written as "{}"', brOpen.getPos());
	}
}

enum abstract EmptyBlockCheckToken(String) {
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
}

enum abstract EmptyBlockCheckOption(String) {
	// allow empty blocks but enforce "{}" notation
	var EMPTY = "empty";
	// empty blocks must contain something apart from whitespace (comment or statement)
	var TEXT = "text";
	// all blocks must contain at least one statement
	var STATEMENT = "stmt";
}