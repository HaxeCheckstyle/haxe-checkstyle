package checkstyle.checks.design;

/**
	Checks for empty package names.
**/
@name("EmptyPackage")
@desc("Checks for empty package names.")
class EmptyPackageCheck extends Check {
	/**
		enforce using a package declaration, even if it is empty
	**/
	public var enforceEmptyPackage:Bool;

	public function new() {
		super(TOKEN);
		enforceEmptyPackage = false;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var packageTokens = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdPackage):
					FoundSkipSubtree;
				case Kwd(_):
					SkipSubtree;
				default:
					GoDeeper;
			}
		});
		if (enforceEmptyPackage) {
			if (packageTokens.length == 0) log("Missing package declaration", 1, 0, 1, 0, MISSING_PACKAGE);
		}
		else checkPackageNames(packageTokens);
	}

	function checkPackageNames(entries:Array<TokenTree>) {
		for (entry in entries) {
			var firstChild = entry.getFirstChild();
			if (firstChild.matches(Semicolon)) logRange("Found empty package", entry.pos.min, firstChild.pos.max, REDUNDANT_PACKAGE);
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "enforceEmptyPackage",
				values: [true, false]
			}]
		}];
	}
}

enum abstract EmptyPackageCode(String) to String {
	var MISSING_PACKAGE = "MissingPackage";
	var REDUNDANT_PACKAGE = "RedundantPackage";
}