package checkstyle.checks.coding;

/**
	Checks for identical or similar code.
**/
@name("ArrowFunction")
@desc("Checks for use of curlies, nested (non-arrow) functions or returns in arrow functions.")
class ArrowFunctionCheck extends Check {
	/**
		allow using `return` inside arrow function bodies
	**/
	public var allowReturn:Bool;

	/**
		allow using `function` inside arrow function bodies
	**/
	public var allowFunction:Bool;

	/**
		allow using curly block as arrow function body (`{...}`)
	**/
	public var allowCurlyBody:Bool;

	/**
		allow using parenthesis around single argument arrow function (`(arg) -> arg * 2`)
	**/
	public var allowSingleArgParens:Bool;

	public function new() {
		super(TOKEN);
		allowReturn = false;
		allowFunction = false;
		allowCurlyBody = false;
		allowSingleArgParens = false;
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
		if (!allowCurlyBody) {
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
		}
		arrow.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			switch (token.tok) {
				case Arrow:
					if (token.index == arrow.index) return GO_DEEPER;
					return SKIP_SUBTREE;
				case Kwd(KwdFunction):
					if (allowFunction) return SKIP_SUBTREE;
					logPos("Arrow function should not include nested functions", token.pos);
					return SKIP_SUBTREE;
				case Kwd(KwdReturn):
					if (allowReturn) return GO_DEEPER;
					logPos("Arrow function should not have explicit returns", token.pos);
					return SKIP_SUBTREE;
				default:
					return GO_DEEPER;
			}
		});
		if (allowSingleArgParens) return;
		var parent:Null<TokenTree> = arrow.parent;
		if ((parent == null) || (parent.tok == null)) return;
		if (!parent.is(POpen)) return;
		var count:Int = 0;
		for (child in parent.children) {
			switch (child.tok) {
				case Arrow:
					break;
				case PClose:
					break;
				default:
					count++;
			}
		}
		if (count == 1) logPos("Arrow function should not use parens for single argument invocation", parent.pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "allowReturn",
				values: [false, true]
			}, {
				propertyName: "allowFunction",
				values: [false, true]
			}, {
				propertyName: "allowCurlyBody",
				values: [false, true]
			}, {
				propertyName: "allowSingleArgParens",
				values: [false, true]
			}]
		}];
	}
}