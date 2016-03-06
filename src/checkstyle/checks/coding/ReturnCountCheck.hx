package checkstyle.checks.coding;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("ReturnCount")
@desc("Restricts the number of return statements in functions (2 by default)")
class ReturnCountCheck extends Check {

	public var max:Int;

	public function new() {
		super();
		max = 2;
	}

	override function actualRun() {
		forEachField(function(f, _) {
			switch (f.kind) {
				case FFun(fun):
					scanBlock(fun.expr);
				default:
			}
		});
	}

	function scanBlock(e:Expr) {
		if (e == null) return;
		var cnt = 0;

		switch (e.expr) {
			case EBlock(exprs):
				for (e in exprs) {
					switch (e.expr) {
						case EReturn(_):
							cnt++;
							if (cnt > max) {
								warnReturnCount(cnt, e.pos);
								return;
							}
						default:
					}
				}
			default:
		}
	}

	function warnReturnCount(cnt:Int, pos:Position) {
		logPos('Return count is $cnt (max allowed is ${max})', pos, severity);
	}
}