package checkstyle.checks.type;

import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.ArrayUtils;
using checkstyle.utils.FieldUtils;

@name("Type")
@desc("Type check for member variables")
class TypeCheck extends Check {

	public var ignoreEnumAbstractValues:Bool;

	public function new() {
		super(AST);
		ignoreEnumAbstractValues = true;
		categories = ["Clarity"];
		points = 1;
	}

	override function actualRun() {
		forEachField(function(f, p) {
			if (f.isConstructor()) return;
			if (ignoreEnumAbstractValues && p.kind == ENUM_ABSTRACT && !f.access.contains(AStatic)) return;
			switch (f.kind) {
				case FVar(t, e):
					if (t == null) error(f.name, f.pos);
				case _:
			}
		});
	}

	function error(name:String, pos:Position) {
		logPos('Type not specified: ${name}', pos);
	}
}