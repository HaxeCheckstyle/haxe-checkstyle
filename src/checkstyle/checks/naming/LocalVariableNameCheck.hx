package checkstyle.checks.naming;

/**
	Checks that the local variable names conform to a format specified by the "format" property.
**/
@name("LocalVariableName")
@desc("Checks that the local variable names conform to a format specified by the `format` property.")
class LocalVariableNameCheck extends NameCheckBase<LocalVariableNameCheckToken> {
	public function new() {
		super();
		format = LOWER_CASE;
	}

	override function actualRun() {
		formatRE = new EReg(format, "");
		if (checker.ast == null) return;
		checker.ast.walkFile(function(e) {
			switch (e.expr) {
				case EVars(vars):
					if (ignoreExtern && isPosExtern(e.pos)) return;
					if (isPosSuppressed(e.pos)) return;

					for (v in vars) {
						if (hasToken(FINAL) != hasToken(NOTFINAL)) { // != -> xor
							if (!hasToken(FINAL) && v.isFinal) continue;
							if (!hasToken(NOTFINAL) && !v.isFinal) continue;
						}

						matchTypeName("local var", v.name, e.pos);
					}
				default:
			}
		});
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [{
				propertyName: "tokens",
				value: [FINAL]
			}],
			properties: [{
				propertyName: "format",
				values: [UPPER_CASE, CAMEL_CASE, LOWER_CASE]
			}]
		}, {
			fixed: [{
				propertyName: "tokens",
				value: [NOTFINAL]
			}],
			properties: [{
				propertyName: "format",
				values: [UPPER_CASE, CAMEL_CASE, LOWER_CASE]
			}]
		}];
	}
}

/**
	supports final and non final constants
	- FINAL = "final"
	- NOTFINAL = "var"
**/
enum abstract LocalVariableNameCheckToken(String) {
	var FINAL = "FINAL";
	var NOTFINAL = "NOTFINAL";
}

enum abstract LocalVariableNameCheckFormt(String) to String {
	var UPPER_CASE = "^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$";
	var CAMEL_CASE = "^[A-Z]+[a-zA-Z0-9]*$";
	var LOWER_CASE = "^[a-z][a-zA-Z0-9]*$";
}