package checkstyle.checks.naming;

import haxe.io.Path;

/**
	Checks that file names match the case of their module name.
**/
@name("FileNameCase")
@desc("Checks that file names match the case of their module name.")
class FileNameCaseCheck extends Check {
	public function new() {
		super(TOKEN);
	}

	override function actualRun() {
		var fileName:String = Path.withoutDirectory(checker.file.name);
		fileName = Path.withoutExtension(fileName);
		checkFile(fileName, checker);
	}

	function checkFile(fileName:String, checker:Checker) {
		var types:Array<String> = getTypes(checker.getTokenTree());
		var lowerFileName:String = fileName.toLowerCase();
		if (fileName == "import") {
			if (types.length <= 0) {
				return;
			}
			log('"import.hx" contains types', 0, 0, 0, 0);
			return;
		}
		if ((lowerFileName == "import") && (types.length == 0)) {
			// ImPort.hx with types
			log('"$fileName.hx" contains no types - consider renaming to "import.hx"', 0, 0, 0, 0);
			return;
		}
		if (!types.contains(fileName)) {
			for (type in types) {
				var lowerType:String = type.toLowerCase();
				if (lowerType == lowerFileName) {
					log('"$fileName.hx" defines type "$type" using different case', 0, 0, 0, 0);
				}
			}
			log('"$fileName.hx" defines no type with name "$fileName"', 0, 0, 0, 0);
			return;
		}
	}

	function getTypes(token:TokenTree):Array<String> {
		var types:Array<TokenTree> = checker.getTokenTree().filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});
		var typeNames:Array<String> = [];
		for (type in types) {
			switch (type.tok) {
				case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef):
					var child:Null<TokenTree> = type.getFirstChild();
					if (child == null) {
						continue;
					}
					switch (child.tok) {
						case Const(CIdent(s)):
							typeNames.push(s);
						default:
					}
				default:
			}
		}

		return typeNames;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.WARNING]
			}]
		}];
	}
}