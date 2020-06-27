package checkstyle.checks.coding;

/**
	Check that the "default" is after all the cases in a "switch" statement. Haxe allows "default" anywhere within the "switch" statement.
	But it is more readable if it comes after the last "case".
**/
@name("DefaultComesLast")
@desc("Check that the `default` is after all the cases in a `switch` statement. Haxe allows `default` anywhere within the `switch` statement. But it is more readable if it comes after the last `case`.")
class DefaultComesLastCheck extends Check {
	public function new() {
		super(TOKEN);
		categories = [Category.STYLE, Category.CLARITY];
		points = 2;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filter([Kwd(KwdSwitch)], All);

		for (token in acceptableTokens) {
			var tokens:Array<TokenTree> = token.filter([Kwd(KwdCase), Kwd(KwdDefault)], First);
			if (tokens.length <= 0) continue;
			if (tokens[tokens.length - 1].is(Kwd(KwdDefault))) continue;

			for (i in 0...tokens.length) {
				if (tokens[i].is(Kwd(KwdDefault)) && i < tokens.length - 1) {
					logPos('Default should be last label in the "switch"', token.pos);
					continue;
				}
			}
		}
	}
}