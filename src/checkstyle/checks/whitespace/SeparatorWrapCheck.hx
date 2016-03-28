package checkstyle.checks.whitespace;

import haxeparser.Data;

@name("SeparatorWrap")
@desc("Checks line wrapping with separators.")
class SeparatorWrapCheck extends WrapCheckBase {

	public function new() {
		super();
		tokens = [
			",",
			"."
		];
	}

	override function actualRun() {
		var tokenList:Array<TokenDef> = [];

		if (hasToken(",")) tokenList.push(Comma);
		if (hasToken(".")) tokenList.push(Dot);

		if (tokenList.length <= 0) return;
		checkTokens(tokenList);
	}
}