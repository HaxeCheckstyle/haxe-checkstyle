package checkstyle.checks.size;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.ArrayUtils;

@name("ParameterNumber")
@desc("Max number of parameters per method (default 7)")
class ParameterNumberCheck extends Check {

	static var DEFAULT_MAX_PARAMS:Int = 7;

	public var max:Int;
	public var ignoreOverriddenMethods:Bool;

	public function new() {
		super(AST);
		max = DEFAULT_MAX_PARAMS;
		ignoreOverriddenMethods = false;
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, _) {
		if (ignoreOverriddenMethods && f.access.contains(AOverride)) return;
		switch (f.kind) {
			case FFun(fun):
				if ((fun.args != null) && (fun.args.length > max)) {
					warnMaxParameter(f.name, f.pos);
				}
			default:
		}
	}

	function warnMaxParameter(name:String, pos:Position) {
		logPos('Too many parameters for function: ${name} (> ${max})', pos);
	}
}