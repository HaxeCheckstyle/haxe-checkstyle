package checkstyle.checks.coding;

/**
	Checks for over-complicated boolean expressions. Finds code like "if (b == true), b || true, !false", etc.
**/
@name("SimplifyBooleanExpression")
@desc("Checks for over-complicated boolean expressions. Finds code like `if (b == true), b || true, !false`, etc.")
class SimplifyBooleanExpressionCheck extends Check {
	public function new() {
		super(TOKEN);
		categories = [Category.COMPLEXITY];
		points = 3;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdTrue) | Kwd(KwdFalse) | Binop(OpEq) | Binop(OpNotEq) | Unop(OpNot) | Binop(OpOr) | Binop(OpAnd) | Binop(OpBoolOr) |
					Binop(OpBoolAnd):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (token in acceptableTokens) {
			if (isPosSuppressed(token.pos)) continue;
			if (token.matches(Kwd(KwdTrue)) || token.matches(Kwd(KwdFalse))) checkToken(token);
		}
	}

	function checkToken(token:TokenTree) {
		var parent = token.parent;
		switch (parent.tok) {
			case Binop(OpEq), Binop(OpNotEq), Unop(OpNot), Binop(OpOr), Binop(OpAnd), Binop(OpBoolOr), Binop(OpBoolAnd):
				logPos("Boolean expression can be simplified", token.pos);
			default:
		}
	}
}