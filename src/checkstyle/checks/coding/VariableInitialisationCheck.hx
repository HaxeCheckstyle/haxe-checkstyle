package checkstyle.checks.coding;

import checkstyle.LintMessage.SeverityLevel;
import checkstyle.checks.Check.ParentType;
import haxeparser.Data;
import haxe.macro.Expr;

@name("VariableInitialisation")
@desc("Checks if instance variables are initialised at class level")
class VariableInitialisationCheck extends Check {

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, p:ParentType) {
		if (f.name == "new" || p.kind == INTERFACE || p.kind == ENUM_ABSTRACT) return;

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
					warnVarInit(f.name, f.pos);
				case _:
			}
		}
	}

	function warnVarInit(name:String, pos:Position) {
		logPos('Invalid variable initialisation: ${name} (move initialisation to constructor or function)', pos, severity);
	}
}