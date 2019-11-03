package checkstyle.checks.size;

import checkstyle.utils.PosHelper;

/**
	Checks the number of parameters of a method.
**/
@name("ParameterNumber")
@desc("Checks the number of parameters of a method.")
class ParameterNumberCheck extends Check {
	static var DEFAULT_MAX_PARAMS:Int = 7;

	/**
		maximum number of parameters per method (default: 7)
	**/
	public var max:Int;

	/**
		ignore methods with "override", only base class violates
	**/
	public var ignoreOverriddenMethods:Bool;

	public function new() {
		super(AST);
		max = DEFAULT_MAX_PARAMS;
		ignoreOverriddenMethods = false;
		categories = [Category.COMPLEXITY, Category.CLARITY];
		points = 5;
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, _) {
		if (ignoreOverriddenMethods && f.access.contains(AOverride)) return;
		switch (f.kind) {
			case FFun(fun):
				if ((fun.args != null) && (fun.args.length > max)) {
					warnMaxParameter(f.name, PosHelper.makeFieldSignaturePosition(f));
				}
			default:
		}
	}

	function warnMaxParameter(name:String, pos:Position) {
		logPos('Too many parameters for function: ${name} (> ${max})', pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "max",
				values: [for (i in 4...15) i]
			}, {
				propertyName: "ignoreOverriddenMethods",
				values: [true, false]
			}]
		}];
	}
}