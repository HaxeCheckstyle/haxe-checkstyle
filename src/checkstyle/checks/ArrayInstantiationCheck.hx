package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("ArrayInstantiation")
class ArrayInstantiationCheck extends Check {
	public function new() {
		super();
	}

	override function actualRun() {
		ExprUtils.walkFile(_checker.ast, function(e) {
			switch(e.expr){
				case ENew({pack:[], name:"Array"}, _):
					var lp = _checker.getLinePos(e.pos.min);
					log('Bad array instantiation, use the array literal notation [] which is faster', lp.line + 1, lp.ofs + 1, SeverityLevel.ERROR);
				default:
			}
		});
	}
}

//http://stackoverflow.com/questions/1094723/what-is-array-literal-notation-in-javascript-and-when-should-you-use-it
//http://stackoverflow.com/questions/7375120/why-is-arr-faster-than-arr-new-array
//http://jsperf.com/new-array-vs-literal/15