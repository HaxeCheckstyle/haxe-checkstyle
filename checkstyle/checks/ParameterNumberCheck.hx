package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("ParameterNumber")
@desc("Max number of parameters per method (default 7)")
class ParameterNumberCheck extends Check {

	static var DEFAULT_MAX_PARAMS:Int = 7;

	public var max:Int;
	public var ignoreOverriddenMethods:Bool;

	public function new() {
		super();
		max = DEFAULT_MAX_PARAMS;
		ignoreOverriddenMethods = false;
	}

	override function actualRun() {
		for (td in checker.ast.decls) {
			switch (td.decl) {
				case EClass(d):
					checkFields(d.data);
				case EAbstract(a):
					checkFields(a.data);
				default:
			}
		}
	}

	function checkFields(fields:Array<Field>) {
		for (field in fields) {
			checkField(field);
		}
	}

	function checkField(f:Field) {
		if (ignoreOverriddenMethods && f.access.indexOf(AOverride) >= 0) return;
		if (isCheckSuppressed (f)) return;
		switch (f.kind) {
			case FFun(fun):
				if ((fun.args != null) && (fun.args.length > max)) {
					warnMaxParameter(f.name, f.pos);
				}
			default:
		}
	}

	function warnMaxParameter(name:String, pos:Position) {
		logPos('Too many parameters for function: ${name} (> ${max})', pos, Reflect.field(SeverityLevel, severity));
	}
}