package checkstyle.checks.coding;

/**
	Checks for identical or similar code.
**/
@name("ArrowFunction")
@desc("Checks for use of curlies, nested (non-arrow) functions or returns in arrow functions.")
class ArrowFunctionCheck extends Check {
	public function new() {
		super(TOKEN);
		categories = [STYLE];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var arrowTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Arrow:
					if (isPosSuppressed(token.pos)) SKIP_SUBTREE;
					FOUND_GO_DEEPER;
				default:
					GO_DEEPER;
			}
		});

		for (token in arrowTokens) {
			var type:ArrowType = TokenTreeCheckUtils.determineArrowType(token);
			switch (type) {
				case ARROW_FUNCTION:
					checkArrowFunction(token);
				case FUNCTION_TYPE_HAXE3, FUNCTION_TYPE_HAXE4:
					continue;
			}
		}
	}

	function checkArrowFunction(arrow:TokenTree) {
		var body:Null<TokenTree> = arrow.access().firstChild().token;
		if (body == null) return;
		switch (body.tok) {
			case BrOpen:
				var type:BrOpenType = TokenTreeCheckUtils.getBrOpenType(body);
				switch (type) {
					case OBJECTDECL:
					case BLOCK, TYPEDEFDECL, ANONTYPE, UNKNOWN:
						logPos("Arrow function should not have curlies", body.getPos());
				}
			default:
		}
		arrow.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			switch (token.tok) {
				case Arrow:
					if (token.index == arrow.index) return GO_DEEPER;
					return SKIP_SUBTREE;
				case Kwd(KwdFunction):
					logPos("Arrow function should not include nested functions", token.pos);
					return SKIP_SUBTREE;
				case Kwd(KwdReturn):
					logPos("Arrow function should not have explicit returns", token.pos);
					return SKIP_SUBTREE;
				default:
					return GO_DEEPER;
			}
		});
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.WARNING]
			}]
		}];
	}
}