package checkstyle.checks.coding;

/**
	Restricts nested "try" blocks to a specified depth (default = 1).
**/
@name("NestedTryDepth")
@desc("Restricts nested `try` blocks to a specified depth (default = 1).")
class NestedTryDepthCheck extends Check {
	/**
		maximum number of nested try/catch statemenmts allowed
		setting "max" to 1 allows one inner try/catch
	**/
	public var max:Int;

	public function new() {
		super(AST);
		max = 1;
		categories = [Category.COMPLEXITY];
		points = 5;
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
			warnNestedTryDepth(depth, e.pos);
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
				case ETry(expr, catches):
					scanBlock(expr, depth + 1);
					scanCatches(catches, depth + 1);
				default:
			}
		}
	}

	function scanCatches(catches:Array<Catch>, depth:Int) {
		for (c in catches) {
			scanBlock(c.expr, depth);
		}
	}

	function warnNestedTryDepth(depth:Int, pos:Position) {
		logPos('Nested try depth is $depth (max allowed is ${max})', pos);
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