package checkstyle.checks;

import checkstyle.token.TokenTree;
import haxe.macro.Expr;

@name("EmptyPackage")
@desc("Checks for empty package names")
class EmptyPackageCheck extends Check {

	public var enforceEmptyPackage:Bool;

	public function new() {
		super(TOKEN);
		enforceEmptyPackage = false;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var packageTokens = root.filter([Kwd(KwdPackage)], ALL);
		if (enforceEmptyPackage) {
			if (packageTokens.length == 0) {
				log("Missing package declaration", 1, 0, 0);
			}
		}
		else {
			checkPackageNames(packageTokens);
		}
	}

	function checkPackageNames(entries:Array<TokenTree>) {
		for (entry in entries) {
			var firstChild = entry.getFirstChild();
			if (firstChild.is(Semicolon)) logRange("Found empty package", entry.pos.min, firstChild.pos.max);
		}
	}
}