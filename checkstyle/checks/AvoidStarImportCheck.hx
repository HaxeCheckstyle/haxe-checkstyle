package checkstyle.checks;

import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("AvoidStarImport")
@desc("Checks for .* import and using directives")
class AvoidStarImportCheck extends Check {

	override function actualRun() {
		try {
			var root:TokenTree = checker.getTokenTree();
			checkImports(root.filter([Kwd(KwdImport)], ALL));
		}
		catch (e:String) {
			//TokenTree exception
		}
	}

	function checkImports(importEntries:Array<TokenTree>) {
		for (entry in importEntries) {
			var stars:Array<TokenTree> = entry.filter([Binop(OpMult)], ALL);
			if (stars.length <= 0) continue;
			logPos("Import line uses a star (.*) import - consider using full type names", entry.pos, Reflect.field(SeverityLevel, severity));
		}
	}
}