package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Type")
@desc("Type check for class variables")
class TypeCheck extends Check {

	override function actualRun() {
		checkClassFields();
	}

	function checkClassFields() {
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					for (field in d.data) if (field.name != "new") checkField(field);
				default:
			}
		}
	}

	function checkField(f:Field) {
		if (isCheckSuppressed (f)) return;
		switch(f.kind) {
			case FVar(t, e):
				if (t == null) error(f.name, f.pos);
			case FProp(g, s, t, e):
			case FFun(f):
		}
	}

	function error(name:String, pos:Position) {
		logPos('Type not specified: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}
}