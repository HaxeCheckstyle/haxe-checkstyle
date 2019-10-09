package checkstyle.checks.naming;

/**
	Checks that the local variable names conform to a format specified by the "format" property.
**/
@name("LocalVariableName")
@desc("Checks that the local variable names conform to a format specified by the `format` property.")
class LocalVariableNameCheck extends NameCheckBase<String> {
	public function new() {
		super();
		format = "^[a-z][a-zA-Z0-9]*$";
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
						matchTypeName("local var", v.name, e.pos);
					}
				default:
			}
		});
	}
}