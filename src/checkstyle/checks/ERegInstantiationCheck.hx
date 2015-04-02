package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("ERegInstantiation")
class ERegInstantiationCheck extends Check {

	public static inline var DESC:String = "Checks instantiation of regular expressions";

	public function new() {
		super();
	}

	override function actualRun() {
		ExprUtils.walkFile(_checker.ast, function(e) {
			switch(e.expr){
				case ENew(
					{pack:[], name:"EReg"},
					[{expr:EConst(CString(re)), pos:_}, {expr:EConst(CString(opt)), pos:_}]
				):
					var lp = _checker.getLinePos(e.pos.min);
					log('Bad EReg instantiation', lp.line + 1, lp.ofs + 1, SeverityLevel.ERROR);
				default:
			}
		});
	}
}