package checkstyle.checks.coding;

/**
	Detects inline conditionals. Useful for developers who find inline conditionals hard to read and want forbid them.
 **/
@name("AvoidInlineConditionals")
@desc("Detects inline conditionals. Useful for developers who find inline conditionals hard to read and want forbid them.")
class AvoidInlineConditionalsCheck extends Check {

	public function new() {
		super(AST);
		severity = SeverityLevel.IGNORE;
		categories = [Category.COMPLEXITY];
		points = 3;
	}

	override function actualRun() {
		checker.ast.walkFile(function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr){
				case ETernary(econd, eif, eelse): logPos("Avoid inline conditionals", e.pos);
				default:
			}
		});
	}
}