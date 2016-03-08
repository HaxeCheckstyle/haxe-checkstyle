package checkstyle.checks.coding;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.ArrayUtils;
using checkstyle.utils.FieldUtils;

@name("VariableInitialisation")
@desc("Checks if instance variables are initialised at class level")
class VariableInitialisationCheck extends Check {

	public function new() {
		super(AST);
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, p:ParentType) {
		if (f.isConstructor() || p.kind == INTERFACE || p.kind == ENUM_ABSTRACT) return;

		var isPrivate = false;
		var isPublic = false;
		var isInline = false;
		var isStatic = false;

		if (f.access.contains(AInline)) isInline = true;
		else if (f.access.contains(AStatic)) isStatic = true;
		else if (f.access.contains(APublic)) isPublic = true;
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
		logPos('Invalid variable initialisation: ${name} (move initialisation to constructor or function)', pos);
	}
}