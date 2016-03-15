package checkstyle.checks.literal;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;

@name("ERegLiteral", "ERegInstantiation")
@desc("Checks for usage of EReg literals (between ~/ and /) instead of new.")
class ERegLiteralCheck extends Check {

	public function new() {
		super(AST);
		categories = ["Style", "Clarity"];
		points = 1;
	}

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr){
				case ENew(
					{pack:[], name:"EReg"},
					[{expr:EConst(CString(re)), pos:_}, {expr:EConst(CString(opt)), pos:_}]
				):
					if (~/\$\{.+\}/.match(re)) return;
					logPos('Bad EReg instantiation, define expression between ~/ and /', e.pos);
				default:
			}
		});
	}
}