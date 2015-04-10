package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Type")
@desc("Type check for class variables")
class TypeCheck extends Check {

	public var severity:String = "ERROR";

	override function _actualRun() {
		checkClassFields();
	}

	function checkClassFields() {
		for (td in _checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					for (field in d.data) if (field.name != "new") checkField(field);
				default:
			}
		}
	}

	function checkField(f:Field) {
		switch(f.kind) {
			case FVar(t, e):
				if (t == null) _error(f.name, f.pos);
			case FProp(g, s, t, e):
			case FFun(f):
		}
	}

	function _error(name:String, pos:Position) {
		logPos('Missing type: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}
}