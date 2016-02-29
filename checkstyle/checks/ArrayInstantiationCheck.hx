package checkstyle.checks;

import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("ArrayInstantiation")
@desc("Checks if the array is instantiated using [], not with new")
class ArrayInstantiationCheck extends Check {

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e:Expr) {
			switch(e.expr){
				case ENew({pack:[], name:"Array"}, _):
					logPos('Bad array instantiation, use the array literal notation [] which is faster', e.pos, Reflect.field(SeverityLevel, severity));
				default:
			}
		});
	}
}