package checkstyle.checks.type;

/**
	Checks if type is specified or not for member variables.
**/
@name("EnforceVarTypeHint")
@desc("Checks if all variables have type hint.")
class EnforceVarTypeHintCheck extends Check {
	/**
		ignores fields inside abstract enums
	**/
	public var ignoreEnumAbstractValues:Bool;

	public function new() {
		super(TOKEN);
		ignoreEnumAbstractValues = true;
		categories = [CLARITY, BUG_RISK];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			switch (token.tok) {
				#if haxe4
				case Kwd(KwdFinal):
					checkVar(token);
					return SKIP_SUBTREE;
				#else
				case Const(CIdent("final")):
					checkVar(token);
					return SKIP_SUBTREE;
				#end
				case Kwd(KwdVar):
					checkVar(token);
					return SKIP_SUBTREE;
				default:
					return GO_DEEPER;
			}
		});
	}

	function checkVar(token:TokenTree) {
		if (isPosSuppressed(token.pos)) return;
		var name:Null<TokenTree> = token.access().firstChild().token;
		if (name == null) return;
		var colon:Null<TokenTree> = name.access().firstOf(DblDot).token;
		if (colon != null) return;
		if (ignoreEnumAbstractValues && isEnumAbstractValue(token)) return;
		error(name.toString(), name.pos);
	}

	function isEnumAbstractValue(token:TokenTree):Bool {
		var parent:Null<TokenTree> = token.parent;
		while ((parent != null) && (parent.tok != null)) {
			switch (parent.tok) {
				case Kwd(KwdAbstract):
					return TokenTreeCheckUtils.isTypeEnumAbstract(parent);
				case Kwd(KwdInterface):
					return false;
				case Kwd(KwdClass):
					return false;
				case Kwd(KwdEnum):
					return false;
				case Kwd(KwdTypedef):
					return false;
				default:
			}
			parent = parent.parent;
		}
		return false;
	}

	function error(name:String, pos:Position) {
		logPos('Variable "${name}" has no type hint', pos);
	}
}