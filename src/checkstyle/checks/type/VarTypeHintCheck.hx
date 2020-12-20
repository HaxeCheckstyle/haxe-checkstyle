package checkstyle.checks.type;

/**
	Checks if type is specified or not for member variables.
**/
@name("VarTypeHint", "EnforceVarTypeHint")
@desc("Checks type hints of variables.")
class VarTypeHintCheck extends Check {
	/**
		policy for type hints on var and final
	**/
	public var typeHintPolicy:VarTypeHintPolicy;

	/**
		ignores fields inside abstract enums
	**/
	public var ignoreEnumAbstractValues:Bool;

	public function new() {
		super(TOKEN);
		typeHintPolicy = INFER_NEW_OR_CONST;
		ignoreEnumAbstractValues = true;
		categories = [CLARITY, BUG_RISK];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var varList:Array<TokenTree> = root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdFinal):
					FoundSkipSubtree;
				case Kwd(KwdVar):
					FoundSkipSubtree;
				default:
					return GoDeeper;
			}
		});
		for (v in varList) {
			checkVar(v);
		}
	}

	function checkVar(token:TokenTree) {
		if (isPosSuppressed(token.pos)) return;
		if (!token.hasChildren()) return;

		for (child in token.children) {
			checkVarName(child);
		}
	}

	function checkVarName(name:TokenTree) {
		if (ignoreEnumAbstractValues && isEnumAbstractValue(name)) return;
		switch (name.tok) {
			case Root:
				return;
			case Question:
				checkVarName(name.getFirstChild());
				return;
			default:
		}
		var colon:Null<TokenTree> = name.access().firstOf(DblDot).token;
		var opAssign:Null<TokenTree> = name.access().firstOf(Binop(OpAssign)).token;
		var hasNewOrConst:Bool = detectNewOrConst(opAssign);
		switch (typeHintPolicy) {
			case ENFORCE_ALL:
				if (colon == null) needsTypeHint(name.toString(), name.pos);

			case INFER_NEW_OR_CONST if (opAssign == null):
				if (colon != null) return;
				needsTypeHint(name.toString(), name.pos);
			case INFER_NEW_OR_CONST if (colon == null):
				if (hasNewOrConst) return;
				needsTypeHint(name.toString(), name.pos);
			case INFER_NEW_OR_CONST:
				if (!hasNewOrConst) return;
				noTypeHintNeeded(name.toString(), name.pos);

			case INFER_ALL if (opAssign == null):
				if (colon != null) return;
				needsTypeHint(name.toString(), name.pos);
			case INFER_ALL:
				if (colon != null) noTypeHintNeeded(name.toString(), name.pos);
		}
	}

	function detectNewOrConst(token:TokenTree):Bool {
		if (token == null) return false;
		for (child in token.children) {
			switch (child.tok) {
				case Const(CString(_)) | Const(CInt(_)) | Const(CFloat(_)) | Const(CRegexp(_)):
					return true;
				case Kwd(KwdTrue) | Kwd(KwdFalse):
					return true;
				case Kwd(KwdNew):
					return true;
				case Semicolon:
					return false;
				default:
			}
		}
		return false;
	}

	function isEnumAbstractValue(token:TokenTree):Bool {
		var parent:Null<TokenTree> = token.parent;
		while ((parent != null) && (parent.tok != Root)) {
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

	function needsTypeHint(name:String, pos:Position) {
		logPos('"${name}" should have a type hint', pos);
	}

	function noTypeHintNeeded(name:String, pos:Position) {
		logPos('"${name}" type hint not needed', pos);
	}
}

/**
	enforce_all = var / final require a type hint
	infer_new_or_const = var / final require a type hint unless you assign a number, a string or new <Object>
	infer_all = var / final only require a type hint if you do not assign anything
**/
enum abstract VarTypeHintPolicy(String) {
	var ENFORCE_ALL = "enforce_all";
	var INFER_NEW_OR_CONST = "infer_new_or_const";
	var INFER_ALL = "infer_all";
}