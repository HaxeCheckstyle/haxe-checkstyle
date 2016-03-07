package checkstyle.checks.coding;

import checkstyle.token.TokenTree;
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
		var root:TokenTree = checker.getTokenTree();
		var functions = root.filter([Kwd(KwdFunction)], ALL);
		for (fn in functions) {
			if (isPosSuppressed(fn.pos)) continue;
			if (!fn.hasChilds()) throw "function has invalid structure!";
			var returns = fn.filter([Kwd(KwdReturn)], ALL);
			if (returns.length > max) {
				logPos('Return count is ${returns.length} (max allowed is ${max})', fn.pos, severity);
			}
		}
	}
}