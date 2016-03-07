package checkstyle.checks;

import checkstyle.token.TokenTree;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("AvoidStarImport")
@desc("Checks for .* import and using directives")
class AvoidStarImportCheck extends Check {

	public function new() {
		super(TOKEN);
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		checkImports(root.filter([Kwd(KwdImport)], ALL));
	}

	function checkImports(importEntries:Array<TokenTree>) {
		for (entry in importEntries) {
			var stars:Array<TokenTree> = entry.filter([Binop(OpMult)], ALL);
			if (stars.length <= 0) continue;
			logPos("Import line uses a star (.*) import - consider using full type names", entry.pos, severity);
		}
	}
}