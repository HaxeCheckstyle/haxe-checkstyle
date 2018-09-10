package checkstyle.checks.coding;

/**
	Restricts nested loop blocks to a specified depth (default = 1).
**/
@name("NestedForDepth")
@desc("Restricts nested loop blocks to a specified depth (default = 1).")
class NestedForDepthCheck extends Check {
	/**
		maximum number of nested loops allowed
		setting "max" to 1 allows one inner loop
	**/
	public var max:Int;

	public function new() {
		super(AST);
		max = 1;
		categories = [Category.COMPLEXITY];
		points = 8;
	}

	override function actualRun() {
		forEachField(function(f, _) {
			switch (f.kind) {
				case FFun(fun):
					scanBlock(fun.expr, -1);
				default:
			}
		});
	}

	function scanBlock(e:Expr, depth:Int) {
		if (e == null) return;
		if (depth > max) {
			warnNestedForDepth(depth, e.pos);
			return;
		}
		switch (e.expr) {
			case EBlock(exprs):
				scanExprs(exprs, depth);
			default:
		}
	}

	function scanExprs(exprs:Array<Expr>, depth:Int) {
		for (e in exprs) {
			switch (e.expr) {
				case EFor(_, expr):
					scanBlock(expr, depth + 1);
				case EWhile(_, expr, _):
					scanBlock(expr, depth + 1);
				default:
			}
		}
	}

	function warnNestedForDepth(depth:Int, pos:Position) {
		logPos('Nested loop depth is $depth (max allowed is ${max})', pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "max",
				values: [for (i in 0...5) i]
			}]
		}];
	}
}