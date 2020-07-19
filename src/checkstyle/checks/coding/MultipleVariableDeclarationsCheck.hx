package checkstyle.checks.coding;

/**
	Checks that each variable declaration is in its own statement and on its own line.
**/
@name("MultipleVariableDeclarations")
@desc("Checks that each variable declaration is in its own statement and on its own line.")
class MultipleVariableDeclarationsCheck extends Check {
	public function new() {
		super(TOKEN);
		categories = [Category.STYLE, Category.CLARITY, Category.COMPLEXITY];
		points = 2;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdVar):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		var lastVarLineNo = -1;
		for (v in acceptableTokens) {
			var curVarLineNo = checker.getLinePos(v.pos.min).line;
			if (lastVarLineNo > 0 && lastVarLineNo == curVarLineNo) logPos("Only one variable definition per line allowed", v.pos);
			lastVarLineNo = curVarLineNo;
			var count = 0;
			for (c in v.children) {
				switch (c.tok) {
					case Const(CIdent(name)):
						count++;
					default:
				}
			}
			if (count > 1) logPos("Each variable declaration must be in its own statement", v.pos);
		}
	}
}