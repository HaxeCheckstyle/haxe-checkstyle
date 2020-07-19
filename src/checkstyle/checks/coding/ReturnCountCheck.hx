package checkstyle.checks.coding;

import checkstyle.utils.PosHelper;

/**
	Restricts the number of return statements in methods (2 by default). Ignores methods that matches "ignoreFormat" regex property.
**/
@name("ReturnCount")
@desc("Restricts the number of return statements in methods (2 by default). Ignores methods that matches `ignoreFormat` regex property.")
class ReturnCountCheck extends Check {
	/**
		maximum number of return calls a function may have
	**/
	public var max:Int;

	/**
		ignore function names matching "ignoreFormat" regex
	**/
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
		var functions = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdFunction):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
		for (fn in functions) {
			if (fn.children == null) continue;
			switch (fn.getFirstChild().tok) {
				case Const(CIdent(name)):
					if (ignoreFormatRE.match(name)) continue;
				default:
			}
			if (isPosSuppressed(fn.pos)) continue;
			if (!fn.hasChildren()) continue;
			var returns = fn.filterCallback(filterReturns);
			if (returns.length > max) {
				logPos('Return count is ${returns.length} (max allowed is ${max})', PosHelper.getReportPos(fn));
			}
		}
	}

	function filterReturns(token:TokenTree, depth:Int):FilterResult {
		return switch (token.tok) {
			case Kwd(KwdFunction):
				// top node is always a function node
				if (depth == 0) GoDeeper; else SkipSubtree;
			case Kwd(KwdReturn): FoundSkipSubtree;
			default: GoDeeper;
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "max",
				values: [for (i in 2...20) i]
			}]
		}];
	}
}