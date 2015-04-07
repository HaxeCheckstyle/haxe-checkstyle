package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Anonymous")
@desc("Anonymous type structures check")
class AnonymousCheck extends Check {

	public var severity:String = "ERROR";

	override function _actualRun() {
		checkClassFields();
		checkLocalVars();
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
		if (Std.string(f.kind).indexOf("TAnonymous") > -1) _error(f.name, f.pos);
	}

	function checkLocalVars() {
		ExprUtils.walkFile(_checker.ast, function(e) {
			switch(e.expr){
				case EVars(vars):
					for (v in vars) if (Std.string(v).indexOf("TAnonymous") > -1) _error(v.name, e.pos);
				default:
			}
		});
	}

	function _error(name:String, pos:Position) {
		logPos('Anonymous structure found, it is advised to use a typedef instead \"${name}\"', pos, Reflect.field(SeverityLevel, severity));
	}
}