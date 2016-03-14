package checkstyle.checks.coding;

import checkstyle.token.TokenTree;
import haxe.macro.Expr;

@name("ReturnCount")
@desc("Restricts the number of return statements in functions (2 by default)")
class ReturnCountCheck extends Check {

	public var max:Int;
	public var ignoreFormat:String;

	public function new() {
		super(TOKEN);
		max = 2;
		ignoreFormat = "^$";
		categories = ["Complexity"];
		points = 5;
	}

	override function actualRun() {
		var ignoreFormatRE:EReg = new EReg(ignoreFormat, "");
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
			var returns = fn.filterCallback(filterReturns);
			if (returns.length > max) {
				logPos('Return count is ${returns.length} (max allowed is ${max})', fn.pos);
			}
		}
	}

	function filterReturns(token:TokenTree, depth:Int):FilterResult {
		return switch (token.tok) {
			case Kwd(KwdFunction):
				// top node is always a function node
				if (depth == 0) GO_DEEPER;
				else SKIP_SUBTREE;
			case Kwd(KwdReturn): FOUND_SKIP_SUBTREE;
			default: GO_DEEPER;
		}
	}
}