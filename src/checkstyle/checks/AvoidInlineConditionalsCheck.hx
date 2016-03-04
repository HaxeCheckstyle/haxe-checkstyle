package checkstyle.checks;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("AvoidInlineConditionals")
@desc("Detects inline conditionals")
class AvoidInlineConditionalsCheck extends Check {

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr){
				case ETernary(econd, eif, eelse):
					logPos('Avoid inline conditionals', e.pos, Reflect.field(SeverityLevel, severity));
				default:
			}
		});
	}
}