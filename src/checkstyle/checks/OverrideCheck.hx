package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Override")
class OverrideCheck extends Check {

	public static inline var DESC:String = "Checks if override is not the starting access modifier";

	public function new() {
		super();
	}

	override function actualRun() {
		for (td in _checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					for (field in d.data) if (field.name != "new") _accessCheck(field);
				default:
			}
		}
	}

	function _accessCheck(f:Field) {
		if (f.access.indexOf(AOverride) > 0) logPos('override access modifier should be the at the start of the function for better code readability \"${f.name}\"', f.pos, SeverityLevel.WARNING);
	}
}