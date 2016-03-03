package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Type")
@desc("Type check for member variables")
class TypeCheck extends Check {

	override function actualRun() {
		forEachField(function(f, _) {
			if (f.name == "new") return;
			switch(f.kind) {
				case FVar(t, e):
					if (t == null) error(f.name, f.pos);
				case _:
			}
		});
	}

	function error(name:String, pos:Position) {
		logPos('Type not specified: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}
}