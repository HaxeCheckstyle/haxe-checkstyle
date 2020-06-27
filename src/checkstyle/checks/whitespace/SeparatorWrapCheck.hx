package checkstyle.checks.whitespace;

import checkstyle.checks.whitespace.WrapCheckBase.WrapCheckBaseOption;

/**
	Checks line wrapping with separators.
**/
@name("SeparatorWrap")
@desc("Checks line wrapping with separators.")
class SeparatorWrapCheck extends WrapCheckBase {
	public function new() {
		super();
		tokens = [","];
	}

	override function actualRun() {
		var tokenList:Array<TokenTreeDef> = [];

		if (hasToken(",")) tokenList.push(Comma);
		if (hasToken(".")) tokenList.push(Dot);

		if (tokenList.length <= 0) return;
		checkTokens(tokenList);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "option",
				values: [WrapCheckBaseOption.EOL, WrapCheckBaseOption.NL]
			}]
		}];
	}
}