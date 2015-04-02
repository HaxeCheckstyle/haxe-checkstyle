package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("VariableInitialisation")
class VariableInitialisationCheck extends Check {

	public static inline var DESC:String = "Checks if the normal variables are initialised at class level";

	public function new() {
		super();
	}

	override function actualRun() {
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
			if (field.name != "new") {
				if (d.flags.indexOf(HInterface) > -1) checkInterfaceField(field);
				else checkField(field);
			}
		}
	}

	function checkInterfaceField(f:Field) {
		var isPrivate = false;
		var isPublic = false;
		var isInline = false;
		var isStatic = false;

		if (f.access.indexOf(AInline) > -1) isInline = true;
		else if (f.access.indexOf(AStatic) > -1) isStatic = true;
		else if (f.access.indexOf(APrivate) > -1) isPrivate = true;
		else isPublic = true;

		_genericCheck(isInline, isPrivate, isPublic, isStatic, f);
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

		_genericCheck(isInline, isPrivate, isPublic, isStatic, f);
	}

	function _genericCheck(isInline:Bool, isPrivate:Bool, isPublic:Bool, isStatic:Bool, f:Field) {
		//trace(Std.string(f.kind));
		if (isPrivate || isPublic) {
			if (Std.string(f.kind).indexOf("FVar") > -1 && Std.string(f.kind).indexOf("expr =>") > -1) {
				_warnVarinit(f.name, f.pos);
				return;
			}
		}
	}

	function _warnVarinit(name:String, pos:Position) {
		logPos('Invalid variable initialisation \"${name}\" (move initialisation to constructor or function)', pos, SeverityLevel.ERROR);
	}
}