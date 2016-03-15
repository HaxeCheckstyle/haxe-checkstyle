package checkstyle.checks.coding;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;

@name("AvoidInlineConditionals")
@desc("Detects inline conditionals. Useful for developers who find inline conditionals hard to read and want forbid them.")
class AvoidInlineConditionalsCheck extends Check {

	public function new() {
		super(AST);
		categories = ["Complexity"];
		points = 3;
	}

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr){
				case ETernary(econd, eif, eelse): logPos('Avoid inline conditionals', e.pos);
				default:
			}
		});
	}
}