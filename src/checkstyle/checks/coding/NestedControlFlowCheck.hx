package checkstyle.checks.coding;

/**
	Checks for maximium nesting depth of control flow expressions (`if`, `for`, `while`, `do/while`, `switch` and `try`).
**/
@name("NestedControlFlow")
@desc("Checks for maximium nesting depth of control flow expressions (`if`, `for`, `while`, `do/while`, `switch` and `try`).")
class NestedControlFlowCheck extends Check {
	/**
		maximum number of nested control flow expressions allowed
	**/
	public var max:Int;

	public function new() {
		super(TOKEN);
		max = 3;
		categories = [Category.COMPLEXITY];
		points = 8;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var controlFlowTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdFor):
					FoundGoDeeper;
				case Kwd(KwdIf):
					FoundGoDeeper;
				case Kwd(KwdSwitch):
					FoundGoDeeper;
				case Kwd(KwdDo):
					FoundGoDeeper;
				case Kwd(KwdWhile):
					if ((token.parent != null) && (token.parent.matches(Kwd(KwdDo)))) GoDeeper; else FoundGoDeeper;
				case Kwd(KwdTry):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
		for (token in controlFlowTokens) {
			if (isPosSuppressed(token.pos)) continue;
			checkExpressionDepth(token);
		}
	}

	function checkExpressionDepth(token:TokenTree) {
		var depth:Int = calcDepth(token);
		if (depth > max) warnNestedDepth(depth, token.getPos());
	}

	function calcDepth(token:TokenTree):Int {
		var parent:TokenTree = token.parent;
		var count:Int = 1;
		while ((parent != null) && (parent.tok != Root)) {
			switch (parent.tok) {
				case Kwd(KwdFor):
					count++;
				case Kwd(KwdIf):
					count++;
				case Kwd(KwdSwitch):
					count++;
				case Kwd(KwdDo):
					count++;
				case Kwd(KwdWhile):
					if ((parent.parent == null) || (!parent.parent.matches(Kwd(KwdDo)))) count++;
				case Kwd(KwdTry):
					count++;
				default:
			}
			parent = parent.parent;
		}
		return count;
	}

	function warnNestedDepth(depth:Int, pos:Position) {
		logPos('Nested control flow depth is $depth (max allowed is ${max})', pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "max",
				values: [for (i in 1...5) i]
			}]
		}];
	}
}