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
					if (isPosSuppressed(token.pos)) SkipSubtree;
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (token in arrowTokens) {
			var type:ArrowType = TokenTreeCheckUtils.determineArrowType(token);
			switch (type) {
				case ArrowFunction:
					checkArrowFunction(token);
				case OldFunctionType | NewFunctionType:
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
						case ObjectDecl:
						case Block | TypedefDecl | AnonType | Unknown:
							logPos("Arrow function should not have curlies", body.getPos());
					}
				default:
			}
		}
		arrow.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			switch (token.tok) {
				case Arrow:
					if (token.index == arrow.index) return GoDeeper;
					return SkipSubtree;
				case Kwd(KwdFunction):
					if (allowFunction) return SkipSubtree;
					logPos("Arrow function should not include nested functions", token.pos);
					return SkipSubtree;
				case Kwd(KwdReturn):
					if (allowReturn) return GoDeeper;
					logPos("Arrow function should not have explicit returns", token.pos);
					return SkipSubtree;
				default:
					return GoDeeper;
			}
		});
		if (allowSingleArgParens) return;
		var parent:Null<TokenTree> = arrow.parent;
		if ((parent == null) || (parent.tok == Root)) return;
		if (!parent.matches(POpen)) return;
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