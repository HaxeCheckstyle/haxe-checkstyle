package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("ERegInstantiation")
@desc("Checks instantiation of regular expressions is in between ~/ and /, not with new")
class ERegInstantiationCheck extends Check {

	public var severity:String = "ERROR";

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
					log('Bad EReg instantiation, define expression between ~/ and /', lp.line + 1, lp.ofs + 1, Reflect.field(SeverityLevel, severity));
				default:
			}
		});
	}
}