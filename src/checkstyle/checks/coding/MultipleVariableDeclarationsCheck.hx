package checkstyle.checks.coding;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("MultipleVariableDeclarations")
@desc("Checks that each variable declaration is in its own statement and on its own line")
class MultipleVariableDeclarationsCheck extends Check {

	@SuppressWarnings('checkstyle:MultipleVariableDeclarations')
	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr){
				case EVars(vars):
					if (vars.length > 1) logPos('Each variable declaration must be in its own statement', e.pos, Reflect.field(SeverityLevel, severity));
				default:

			}
		});

		for (i in 0 ... checker.lines.length) {
			if (isLineSuppressed(i)) return;
			var line = checker.lines[i];
			if (~/(var ).*(var ).*;$/.match(line)) log('Only one variable definition per line allowed', i, 0, null, Reflect.field(SeverityLevel, severity));
		}
	}
}