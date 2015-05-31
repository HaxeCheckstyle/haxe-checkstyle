package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("VariableInitialisation")
@desc("Checks if the normal variables are initialised at class level")
class VariableInitialisationCheck extends Check {

	override function actualRun() {
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					checkFields(d);
				default:
			}
		}
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			if (isCheckSuppressed (field)) continue;
			if (field.name != "new") {
				if (d.flags.indexOf(HInterface) == -1) checkField(field);
			}
		}
	}

	function checkField(f:Field) {
		var isPrivate = false;
		var isPublic = false;
		var isInline = false;
		var isStatic = false;

		if (f.access.indexOf(AInline) > -1) isInline = true;
		else if (f.access.indexOf(AStatic) > -1) isStatic = true;
		else if (f.access.indexOf(APublic) > -1) isPublic = true;
		else isPrivate = true;

		if (isPrivate || isPublic) {
			switch (f.kind) {
				case FVar(t, e):
					if (e == null) return;
					warnVarinit(f.name, f.pos);
				case FFun(f):
					return;
				case FProp(g, s, t, a):
					return;
			}
		}
	}

	function warnVarinit(name:String, pos:Position) {
		logPos('Invalid variable initialisation: ${name} (move initialisation to constructor or function)', pos, Reflect.field(SeverityLevel, severity));
	}
}