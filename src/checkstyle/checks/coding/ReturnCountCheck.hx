package checkstyle.checks.coding;

import checkstyle.token.TokenTree;
import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("ReturnCount")
@desc("Restricts the number of return statements in functions (2 by default)")
class ReturnCountCheck extends Check {

	public var max:Int;
	public var ignoreFormat:String;

	public function new() {
		super();
		max = 2;
		ignoreFormat = "^$";
	}

	override function actualRun() {
		var ignoreFormatRE:EReg  = new EReg(ignoreFormat, "");
		var root:TokenTree = checker.getTokenTree();
		var functions = root.filter([Kwd(KwdFunction)], ALL);
		for (fn in functions) {
			switch (fn.getFirstChild().tok) {
				case Const(CIdent(name)):
					if (ignoreFormatRE.match(name)) continue;
				default:
			}
			if (isPosSuppressed(fn.pos)) continue;
			if (!fn.hasChilds()) throw "function has invalid structure!";
			var returns = fn.filter([Kwd(KwdReturn)], ALL);
			if (returns.length > max) {
				logPos('Return count is ${returns.length} (max allowed is ${max})', fn.pos, severity);
			}
		}
	}
}