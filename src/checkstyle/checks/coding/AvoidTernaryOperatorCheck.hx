package checkstyle.checks.coding;

/**
	Detects ternary operators. Useful for developers who find ternary operators hard to read and want forbid them.
**/
@name("AvoidTernaryOperator", "AvoidInlineConditionals")
@desc("Detects ternary operators. Useful for developers who find ternary operators hard to read and want forbid them.")
class AvoidTernaryOperatorCheck extends Check {

	/**
	 	the maximum number of levels of depth a ternary operator can be nested in
		0 (default) = no ternaries allowed
		1 = no nested ternaries
		2 = no nested ternaries inside nested ternaries, etc.
	**/
	public var maxDepth:Int;

	public function new() {
		super(AST);
		severity = SeverityLevel.IGNORE;
		categories = [Category.COMPLEXITY];
		points = 3;

		maxDepth = 0;
	}

	override function actualRun() {
		forEachField(function(f, _) {
			switch (f.kind) {
				case FVar(type, expr):
					scanExprs([expr], 0);
				case FProp(get, set, t, expr):
					scanExprs([expr], 0);
				case FFun(fun):
					scanExprs([fun.expr], 0);
			}
		});
	}

	function scanExprs(exprs:Array<Expr>, ternaryDepth:Int) {
		for (e in exprs) {
			if (e == null) continue;
			if (isPosSuppressed(e.pos)) continue;

			switch (e.expr) {
				case EBlock(exprs):
					scanExprs(exprs, ternaryDepth);
				case EParenthesis(expr):
					scanExprs([expr], ternaryDepth);
				case EVars(vars):
					for (v in vars) scanExprs([v.expr], ternaryDepth);

				case ETernary(_, eif, eelse):
					if (maxDepth == 0) {
						logPos("Avoid use of ternary operators", e.pos);
					}
					else if ((ternaryDepth + 1) > maxDepth) {
						logPos("Maximum ternary depth exceeded", e.pos);
					}
					else {
						scanExprs([eif, eelse], ternaryDepth + 1);
					}
				
				default:
					continue;
			}
		}
	}
}