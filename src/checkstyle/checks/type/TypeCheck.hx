package checkstyle.checks.type;

/**
	Checks if type is specified or not for member variables.
**/
@name("Type")
@desc("Checks if type is specified or not for member variables.")
class TypeCheck extends Check {
	/**
		ignores fields inside abstract enums
	**/
	public var ignoreEnumAbstractValues:Bool;

	public function new() {
		super(AST);
		ignoreEnumAbstractValues = true;
		categories = [Category.CLARITY];
	}

	override function actualRun() {
		forEachField(function(f, p) {
			if (f.isConstructor()) return;
			if (ignoreEnumAbstractValues && p.kind == ENUM_ABSTRACT && !f.access.contains(AStatic)) return;
			switch (f.kind) {
				case FVar(t, e):
					if (t == null) error(f.name, f.pos);
				case _:
			}
		});
	}

	function error(name:String, pos:Position) {
		logPos('Variable "${name}" type not specified', pos);
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