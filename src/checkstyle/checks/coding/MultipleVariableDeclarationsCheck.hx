package checkstyle.checks.coding;

import checkstyle.token.TokenTree;
import haxe.macro.Expr;

@name("MultipleVariableDeclarations")
@desc("Checks that each variable declaration is in its own statement and on its own line")
class MultipleVariableDeclarationsCheck extends Check {

	public function new() {
		super(TOKEN);
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filter([Kwd(KwdVar)], ALL);

		for (v in acceptableTokens) {
			var count = 0;
			for (c in v.childs) {
				switch (c.tok) {
					case Const(CIdent(name)):
						count++;
					default:
				}
			}
			if (count > 1) logPos('Each variable declaration must be in its own statement', v.pos);
		}

		// Need line no of each token to remove line based check
		for (i in 0 ... checker.lines.length) {
			if (isLineSuppressed(i)) return;
			var line = checker.lines[i];
			if (~/(var ).*;.*(var ).*;$/.match(line)) log('Only one variable definition per line allowed', i + 1, 0);
		}
	}
}