package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("ParameterNumber")
@desc("Max number of parameters per method (default 7)")
class ParameterNumberCheck extends Check {

	public var max:Int;
	public var ignoreOverriddenMethods:Bool;

	public function new() {
		super();
		max = 7;
		ignoreOverriddenMethods = false;
	}

	override function actualRun() {
		for (td in checker.ast.decls) {
			switch (td.decl) {
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