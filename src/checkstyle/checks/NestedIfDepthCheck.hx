package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("NestedIfDepth")
@desc("Max number of nested if-else blocks (default 1)")
class NestedIfDepthCheck extends Check {

	public var max:Int;

	public function new() {
		super();
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
			switch(e.expr) {
				case EIf(_, ifPart,elsePart):
					scanBlock(ifPart, depth + 1);
					scanBlock(elsePart, depth + 1);
				default:
			}
		}
	}

	function warnNestedIfDepth(depth:Int, pos:Position) {
		logPos('Nested if-else depth is $depth (max allowed is ${max})', pos, Reflect.field(SeverityLevel, severity));
	}
}