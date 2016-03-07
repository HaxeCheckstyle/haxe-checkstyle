package checkstyle.checks.type;

import checkstyle.LintMessage.SeverityLevel;
import checkstyle.utils.ExprUtils;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.FieldUtils;

@name("Anonymous")
@desc("Anonymous type structures check")
class AnonymousCheck extends Check {

	public function new() {
		super(AST);
	}

	override function actualRun() {
		forEachField(checkField);
		checkLocalVars();
	}

	function checkField(f:Field, _) {
		if (f.isConstructor()) return;
		switch (f.kind) {
			case FVar(TAnonymous(fields), val):
				error(f.name, f.pos);
			default:
		}
	}

	function checkLocalVars() {
		ExprUtils.walkFile(checker.ast, function(e) {
			switch (e.expr){
				case EVars(vars):
					for (v in vars) {
						if (v.type == null) continue;
						switch (v.type) {
							case TAnonymous(fields):
								error(v.name, e.pos);
							default:
						}
					}
				default:
			}
		});
	}

	function error(name:String, pos:Position) {
		logPos('Anonymous structure found, it is advised to use a typedef instead \"${name}\"', pos, severity);
	}
}