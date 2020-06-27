package checkstyle.checks.type;

/**
	Checks for use of Dynamic type anywhere in the code.
**/
@name("Dynamic")
@desc("Checks for use of Dynamic type anywhere in the code.")
class DynamicCheck extends Check {
	public function new() {
		super(TOKEN);
		categories = [Category.CLARITY, Category.BUG_RISK, Category.COMPLEXITY];
		points = 3;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			switch token.tok {
				case Const(CIdent("Dynamic")):
					if (isPosSuppressed(token.pos)) return SkipSubtree;
					logPos('Avoid using "Dynamic" as type', token.pos);
					return SkipSubtree;
				default:
					return GoDeeper;
			}
		});
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.INFO]
			}]
		}];
	}
}