package checkstyle.checks.coding;

/**
	Detects ternary operators. Useful for developers who find ternary operators hard to read and want forbid them.
**/
@name("AvoidTernaryOperator", "AvoidInlineConditionals")
@desc("Detects ternary operators. Useful for developers who find ternary operators hard to read and want forbid them.")
class AvoidTernaryOperatorCheck extends Check {
	public function new() {
		super(AST);
		severity = SeverityLevel.IGNORE;
		categories = [Category.COMPLEXITY];
		points = 3;
	}

	override function actualRun() {
		if (checker.ast == null) return;
		checker.ast.walkFile(function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr) {
				case ETernary(econd, eif, eelse):
					logPos("Avoid ternary operator", e.pos);
				default:
			}
		});
	}
}