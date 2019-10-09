package checkstyle.checks.type;

/**
	Check to find any anonymous type structures used.
**/
@name("Anonymous")
@desc("Check to find any anonymous type structures used.")
class AnonymousCheck extends Check {
	public function new() {
		super(AST);
		categories = [Category.STYLE, Category.CLARITY, Category.BUG_RISK, Category.COMPLEXITY];
		points = 8;
	}

	override function actualRun() {
		forEachField(checkField);
		checkLocalVars();
	}

	function checkField(f:Field, _) {
		if (f.isConstructor()) return;
		switch (f.kind) {
			case FVar(TAnonymous(fields), val):
				error(f.name, f.pos);
			default:
		}
	}

	function checkLocalVars() {
		if (checker.ast == null) return;
		checker.ast.walkFile(function(e) {
			switch (e.expr) {
				case EVars(vars):
					for (v in vars) {
						if (v.type == null) continue;
						switch (v.type) {
							case TAnonymous(fields): error(v.name, e.pos);
							default:
						}
					}
				default:
			}
		});
	}

	function error(name:String, pos:Position) {
		logPos('Anonymous structure "${name}" found, use "typedef"', pos);
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