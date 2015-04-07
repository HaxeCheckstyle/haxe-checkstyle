package checkstyle.checks;

import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("ArrayInstantiation")
@desc("Checks if the array is instantiated using [], not with new")
class ArrayInstantiationCheck extends Check {

	public var severity:String = "ERROR";

	override function _actualRun() {
		ExprUtils.walkFile(_checker.ast, function(e:Expr) {
			switch(e.expr){
				case ENew({pack:[], name:"Array"}, _):
					var lp = _checker.getLinePos(e.pos.min);
					log('Bad array instantiation, use the array literal notation [] which is faster', lp.line + 1, lp.ofs + 1, Reflect.field(SeverityLevel, severity));
				default:
			}
		});
	}
}

//http://stackoverflow.com/questions/1094723/what-is-array-literal-notation-in-javascript-and-when-should-you-use-it
//http://stackoverflow.com/questions/7375120/why-is-arr-faster-than-arr-new-array
//http://jsperf.com/new-array-vs-literal/15