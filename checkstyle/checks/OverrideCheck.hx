package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Override")
@desc("Checks if override is not the starting access modifier")
class OverrideCheck extends Check {

	public var severity:String = "WARNING";

	override function _actualRun() {
		for (td in _checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					for (field in d.data) if (field.name != "new") _overrideCheck(field);
				default:
			}
		}
	}

	function _overrideCheck(f:Field) {
		if (f.access.indexOf(AOverride) > 0) logPos('override access modifier should be the at the start of the function for better code readability: ${f.name}', f.pos, Reflect.field(SeverityLevel, severity));
	}
}