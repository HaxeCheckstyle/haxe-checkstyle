package checkstyle.checks.naming;

import checkstyle.LintMessage.SeverityLevel;
import checkstyle.utils.ExprUtils;
import haxeparser.Data;
import haxe.macro.Expr;

@name("LocalVariableName")
@desc("Checks the local variable names")
class LocalVariableNameCheck extends NameCheckBase<String> {

	public function new() {
		super();
		format = "^[a-z][a-zA-Z0-9]*$";
	}

	override function actualRun() {
		formatRE = new EReg (format, "");
		ExprUtils.walkFile(checker.ast, function(e) {
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