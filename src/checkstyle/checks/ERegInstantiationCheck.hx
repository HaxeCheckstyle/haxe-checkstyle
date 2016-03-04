package checkstyle.checks;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("ERegInstantiation")
@desc("Checks instantiation of regular expressions is in between ~/ and /, not with new")
class ERegInstantiationCheck extends Check {

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e:Expr) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr){
				case ENew(
					{pack:[], name:"EReg"},
					[{expr:EConst(CString(re)), pos:_}, {expr:EConst(CString(opt)), pos:_}]
				):
					logPos('Bad EReg instantiation, define expression between ~/ and /', e.pos, Reflect.field(SeverityLevel, severity));
				default:
			}
		});
	}
}