package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;
import checkstyle.ComplexTypeUtils;

@name("Dynamic")
@desc("Checks for use of Dynamic type")
class DynamicCheck extends Check {

	public var severity:String;

	public function new () {
		super ();
		severity = "INFO";
	}

	override function _actualRun() {
		ComplexTypeUtils.walkFile (_checker.ast, callbackComplexType);
	}

	function callbackComplexType(t:ComplexType, name:String, pos:Position):Void {
		if (t == null) return;
		if (isPosSuppressed (pos)) return;
		switch (t) {
			case TPath(p):
				if (p.name == "Dynamic") _error (name, pos);
			default:
		}
	}

	function _error(name:String, pos:Position) {
		logPos('Dynamic type used: ${name}',
				pos, Reflect.field(SeverityLevel, severity));
	}
}
