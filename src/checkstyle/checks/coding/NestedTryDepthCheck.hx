package checkstyle.checks.coding;

import haxeparser.Data;
import haxe.macro.Expr;

@name("NestedTryDepth")
@desc("Max number of nested try blocks (default 1)")
class NestedTryDepthCheck extends Check {

	public var max:Int;

	public function new() {
		super(AST);
		max = 1;
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
}