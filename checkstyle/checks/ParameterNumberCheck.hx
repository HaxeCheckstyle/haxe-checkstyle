package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("ParameterNumber")
@desc("Max number of parameters per method (default 10)")
class ParameterNumberCheck extends Check {

	public var severity:String = "INFO";
	public var max:Int = 10;

	override function _actualRun() {
		for (td in _checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					checkFields(d);
				default:
			}
		}
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			checkField(field);
		}
	}

	function checkField(f:Field) {
		switch (f.kind) {
			case FFun(fun):
				if ((fun.args != null) && (fun.args.length > max)) {
					_warnMaxParameter(f.name, f.pos);
				}
			default:
		}
	}

	function _warnMaxParameter(name:String, pos:Position) {
		logPos('Too many parameters for function: ${name} (> ${max})', pos, Reflect.field(SeverityLevel, severity));
	}
}
