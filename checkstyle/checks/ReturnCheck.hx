package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Return")
@desc("Warns if Void is used for return or if return type is not specified when returning")
class ReturnCheck extends Check {

	public var severity:String = "INFO";
	public var allowEmptyReturn:Bool = true;
	public var enforceReturnType:Bool = false;
	public var warnVoidReturnType:Bool = true;

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
			if (field.name != "new" && d.flags.indexOf(HInterface) == -1) checkField(field);
		}
	}

	function checkField(f:Field) {
		if (enforceReturnType) {
			switch (f.kind) {
				case FFun(fun):
					if (fun.ret == null) {
						_warnReturnTypeMissing(f.name, f.pos);
					}
					return;
				default:
			}
		}
		else {
			if (warnVoidReturnType && Std.string(f.kind).indexOf("ret => TPath({ name => Void") > -1) {
				_warnVoid(f.name, f.pos);
			}
		}
		if (allowEmptyReturn && Std.string(f.kind).indexOf("EReturn(null)") > -1) return;
		if (Std.string(f.kind).indexOf("expr => EReturn") > -1 && Std.string(f.kind).indexOf("ret => null") > -1) {
			_warnNoReturnType(f.name, f.pos);
		}
	}

	function _warnVoid(name:String, pos:Position) {
		logPos('No need to return Void, Default function return value type is Void: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}

	function _warnNoReturnType(name:String, pos:Position) {
		logPos('Return type not specified when returning a value for function: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}

	function _warnReturnTypeMissing(name:String, pos:Position) {
		logPos('Return type not specified for function: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}
}
