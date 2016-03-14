package checkstyle.checks.coding;

import haxeparser.Data;
import haxe.macro.Expr;

@name("NestedForDepth")
@desc("Max number of nested for blocks (default 1)")
class NestedForDepthCheck extends Check {

	public var max:Int;

	public function new() {
		super(AST);
		max = 1;
		categories = ["Complexity"];
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
		logPos('Nested for depth is $depth (max allowed is ${max})', pos);
	}
}