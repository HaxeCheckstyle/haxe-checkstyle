package checkstyle.checks.imports;

/**
	Checks for import statements that use the * notation and using directives.
**/
@name("AvoidStarImport")
@desc("Checks for import statements that use the * notation and using directives.")
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
			logPos('Using the ".*" form of import should be avoided', entry.getPos());
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [
			{
				fixed: [],
				properties: [{
					propertyName: "severity",
					values: [SeverityLevel.INFO]
				}]
			}
		];
	}
}