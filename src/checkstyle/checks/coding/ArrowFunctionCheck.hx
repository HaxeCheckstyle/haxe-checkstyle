package checkstyle.checks.coding;

/**
	Checks arrow function style.
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

	/**
		enforce using arrow syntax for non-member functions (`function (...) {}` -> `(...) -> ...`)
	**/
	public var enforceArrowForNonMemberFunctions:Bool;

	public function new() {
		super(TOKEN);
		allowReturn = false;
		allowFunction = false;
		allowCurlyBody = false;
		allowSingleArgParens = false;
		enforceArrowForNonMemberFunctions = false;
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

		if (enforceArrowForNonMemberFunctions) {
			checkNonMemberFunctions();
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

	function checkNonMemberFunctions() {
		if (checker.ast == null) return;
		checker.ast.walkFile(function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr) {
				case EFunction(kind, _):
					switch (kind) {
						case FArrow:
						case FAnonymous, FNamed(_, _), null:
							logPos("Non-member function should use arrow syntax", e.pos);
					}
				default:
			}
		});
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
			}, {
				propertyName: "enforceArrowForNonMemberFunctions",
				values: [false, true]
			}]
		}];
	}
}
