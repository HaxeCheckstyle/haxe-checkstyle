package checkstyle.checks.imports;

import checkstyle.token.TokenTree;
import haxe.macro.Expr;

@name("AvoidStarImport")
@desc("Checks for .* import and using directives.")
class AvoidStarImportCheck extends Check {

	public function new() {
		super(TOKEN);
		categories = [Category.STYLE, Category.CLARITY];
		points = 2;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		checkImports(root.filter([Kwd(KwdImport)], ALL));
	}

	function checkImports(importEntries:Array<TokenTree>) {
		for (entry in importEntries) {
			var stars:Array<TokenTree> = entry.filter([Binop(OpMult)], ALL);
			if (stars.length <= 0) continue;
			logPos("Import line uses a star (.*) import - consider using full type names", entry.pos);
		}
	}
}