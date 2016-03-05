package checkstyle.checks.type;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Type")
@desc("Type check for member variables")
class TypeCheck extends Check {

	public var ignoreEnumAbstractValues:Bool;

	public function new() {
		super();
		ignoreEnumAbstractValues = true;
	}

	override function actualRun() {
		forEachField(function(f, p) {
			if (f.name == "new") return;
			if (ignoreEnumAbstractValues && p.kind == ENUM_ABSTRACT && f.access.indexOf(AStatic) == -1) return;
			switch (f.kind) {
				case FVar(t, e):
					if (t == null) error(f.name, f.pos);
				case _:
			}
		});
	}

	function error(name:String, pos:Position) {
		logPos('Type not specified: ${name}', pos, severity);
	}
}