package checkstyle.checks.literal;

/**
	Checks if the array is instantiated using [] which is shorter and cleaner, not with new.
**/
@name("ArrayLiteral", "ArrayInstantiation")
@desc("Checks if the array is instantiated using [] which is shorter and cleaner, not with new.")
class ArrayLiteralCheck extends Check {
	public function new() {
		super(AST);
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		if (checker.ast == null) return;
		checker.ast.walkFile(function(e:Expr) {
			switch (e.expr) {
				case ENew({pack: [], name: "Array"}, _):
					logPos('Bad array instantiation, use the array literal notation "[]" which is shorter and cleaner', e.pos);
				default:
			}
		});
	}
}