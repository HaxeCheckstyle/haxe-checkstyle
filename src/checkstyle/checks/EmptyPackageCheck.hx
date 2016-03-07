package checkstyle.checks;

import checkstyle.token.TokenTree;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("EmptyPackage")
@desc("Checks for empty package names")
class EmptyPackageCheck extends Check {

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		checkPackageNames(root.filter([Kwd(KwdPackage)], ALL));
	}

	function checkPackageNames(entries:Array<TokenTree>) {
		for (entry in entries) {
			if (entry.getFirstChild().is(Semicolon)) logPos("Remove empty package statement", entry.pos, severity);
		}
	}
}