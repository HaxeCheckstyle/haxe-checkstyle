package checkstyle.checks.coding;

/**
	Restricts nested "if-else" blocks to a specified depth (default = 1).
**/
@name("NestedIfDepth")
@desc("Restricts nested `if-else` blocks to a specified depth (default = 1).")
class NestedIfDepthCheck extends Check {
	/**
		maximum number of nested if statements allowed
		setting "max" to 1 allows one if inside another
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
			warnNestedIfDepth(depth, e.pos);
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
				case EIf(_, ifPart, elsePart):
					scanBlock(ifPart, depth + 1);
					scanBlock(elsePart, depth + 1);
				default:
			}
		}
	}

	function warnNestedIfDepth(depth:Int, pos:Position) {
		logPos('Nested if-else depth is $depth (max allowed is ${max})', pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "max",
				values: [for (i in 0...10) i]
			}]
		}];
	}
}