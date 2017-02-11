package checkstyle.checks.coding;

@name("ReturnCount")
@desc("Restricts the number of return statements in methods (2 by default). Ignores methods that matches `ignoreFormat` regex property.")
class ReturnCountCheck extends Check {

	public var max:Int;
	public var ignoreFormat:String;

	public function new() {
		super(TOKEN);
		max = 2;
		ignoreFormat = "^$";
		categories = [Category.COMPLEXITY];
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
			if (!fn.hasChildren()) throw "function has invalid structure!";
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