package checkstyle.checks.type;

import checkstyle.utils.ComplexTypeUtils;

@name("Dynamic")
@desc("Checks for use of Dynamic type anywhere in the code.")
class DynamicCheck extends Check {

	public function new() {
		super(AST);
		categories = [Category.CLARITY, Category.BUG_RISK, Category.COMPLEXITY];
		points = 3;
	}

	override function actualRun() {
		ComplexTypeUtils.walkFile(checker.ast, callbackComplexType);
	}

	function callbackComplexType(t:ComplexType, name:String, pos:Position) {
		if (t == null) return;
		if (isPosSuppressed(pos)) return;
		switch (t) {
			case TPath(p):
				if (p.name == "Dynamic") error(name, pos);
			default:
		}
	}

	function error(name:String, pos:Position) {
		logPos('"${name}" type is "Dynamic"', pos);
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