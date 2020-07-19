package checkstyle.checks.coding;

/**
	Checks for assignments in subexpressions, such as in "if ((a=b) > 0) return;".
**/
@name("InnerAssignment")
@desc("Checks for assignments in subexpressions, such as in `if ((a=b) > 0) return;`.")
class InnerAssignmentCheck extends Check {
	/**
		ignores assignments in return statements
	**/
	public var ignoreReturnAssignments:Bool;

	public function new() {
		super(TOKEN);
		ignoreReturnAssignments = false;
		categories = [Category.COMPLEXITY, Category.CLARITY, Category.BUG_RISK];
		points = 5;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allAssignments:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Binop(OpAssign) | Binop(OpAssignOp(OpAdd)) | Binop(OpAssignOp(OpSub)) | Binop(OpAssignOp(OpDiv)) | Binop(OpAssignOp(OpMult)) |
					Binop(OpAssignOp(OpShl)) | Binop(OpAssignOp(OpShr)) | Binop(OpAssignOp(OpUShr)) | Binop(OpAssignOp(OpAnd)) | Binop(OpAssignOp(OpOr)) |
					Binop(OpAssignOp(OpXor)):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
		for (assignToken in allAssignments) {
			if (isPosSuppressed(assignToken.pos) || !filterAssignment(assignToken)) continue;
			logPos("Inner assignment detected", assignToken.pos);
		}
	}

	function filterAssignment(token:TokenTree):Bool {
		if ((token == null) || (token.tok == Root)) return false;
		if (token.previousSibling != null) {
			// tokenizer does not treat >= as OpGte
			// creates OpGt and OpAssign instead
			if (token.previousSibling.matches(Binop(OpGt))) return false;
		}
		return switch (token.tok) {
			case Kwd(KwdVar): false;
			case Kwd(KwdFunction): false;
			case Kwd(KwdSwitch): true;
			case Kwd(KwdReturn): filterReturn(token);
			case BrOpen, DblDot: false;
			case POpen: filterPOpen(token.parent);
			default: filterAssignment(token.parent);
		}
	}

	function filterPOpen(token:TokenTree):Bool {
		if ((token == null) || (token.tok == Root)) return false;
		return switch (token.tok) {
			case Kwd(KwdFunction): false;
			case Kwd(KwdVar): false;
			case Kwd(KwdNew): !Type.enumEq(Kwd(KwdFunction), token.parent.tok);
			case Kwd(KwdReturn): true;
			case Kwd(KwdWhile): false;
			case POpen, Const(_): filterPOpen(token.parent);
			default: true;
		}
	}

	function filterReturn(token:TokenTree):Bool {
		if (!ignoreReturnAssignments) return true;

		// only ignore return this.value = value when
		// - there are no other Binops apart from =
		// - return is only statement inside block
		// - it is inside of setter function
		var allBinops:Array<TokenTree> = token.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Binop(_): FoundGoDeeper;
				case Unop(_): FoundGoDeeper;
				case POpen, BkOpen, BrOpen: FoundGoDeeper;
				default: GoDeeper;
			}
		});

		if (allBinops.length != 1) return true;
		var parent:TokenTree;
		if (Type.enumEq(token.parent.tok, BrOpen)) {
			var brOpen:TokenTree = token.parent;
			// parent is a block and has more than two children
			if (brOpen.children.length > 2) return true;
			parent = brOpen.parent;
		}
		else {
			parent = token.parent;
			// parent is no block and has more than one child
			if (parent.getLastChild() != token) return true;
		}
		if (!Type.enumEq(parent.parent.tok, Kwd(KwdFunction))) return true;
		switch (parent.tok) {
			case Const(CIdent(name)):
				if (!StringTools.startsWith(name, "set_")) return true;
			default:
				return true;
		}

		return false;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "ignoreReturnAssignments",
				values: [false, true]
			}]
		}];
	}
}