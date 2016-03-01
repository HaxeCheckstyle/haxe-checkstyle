package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.Position;
using haxe.macro.ExprTools;

@name("NullParameter")
@desc("Checks for parameters with a null default value")
class NullParameterCheck extends Check {

	override function actualRun() {
		forEachField(function(field, _) {
			switch (field.kind) {
				case FFun(f):
					for (arg in f.args) checkArgument(arg);
				case _:
			}
		});
	}

	function checkArgument(arg:FunctionArg) {
		if (arg.opt && arg.value.toString() == "null") {
			logPos('Parameter ${arg.name} has a \'?\' and a default value of \'null\', which is redundant', arg.value.pos, Reflect.field(SeverityLevel, severity));
		}
	}
}