package checkstyle.checks.coding;

/**
	Checks switch condition parentheses usage (`switch value {}` vs `switch (value) {}`) when configured.
**/
@name("SwitchParentheses")
@desc("Checks switch condition parentheses usage (`switch value {}` vs `switch (value) {}`) when configured.")
class SwitchParenthesesCheck extends Check {
	/**
		policy for switch condition parentheses:
		- ignore = skip check
		- forbid = disallow parentheses (`switch value {}`)
		- require = require parentheses (`switch (value) {}`)
	**/
	public var policy:SwitchParenthesesPolicy;

	public function new() {
		super(TOKEN);
		categories = [Category.STYLE, Category.CLARITY];
		policy = IGNORE;
	}

	override function actualRun() {
		if (policy == IGNORE) return;

		var root:TokenTree = checker.getTokenTree();
		var switchTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdSwitch):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (switchToken in switchTokens) {
			if (isPosSuppressed(switchToken.pos)) continue;

			var conditionToken = switchToken.getFirstChild();
			if (conditionToken == null) continue;
			var hasParentheses = conditionToken.matches(POpen);
			switch (policy) {
				case REQUIRE:
					if (!hasParentheses) {
						logPos('Switch condition should be wrapped in parentheses', conditionToken.pos, REQUIRE_SWITCH_PARENTHESES);
					}
				case FORBID:
					if (hasParentheses) {
						logPos('Switch condition should not be wrapped in parentheses', conditionToken.pos, NO_SWITCH_PARENTHESES);
					}
				case IGNORE:
			}
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "policy",
				values: [IGNORE, FORBID, REQUIRE]
			}]
		}];
	}
}

enum abstract SwitchParenthesesPolicy(String) {
	var IGNORE = "ignore";
	var FORBID = "forbid";
	var REQUIRE = "require";
}

enum abstract SwitchParenthesesCode(String) to String {
	var NO_SWITCH_PARENTHESES = "NoSwitchParentheses";
	var REQUIRE_SWITCH_PARENTHESES = "RequireSwitchParentheses";
}
