package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("PublicPrivate")
class PublicPrivateCheck extends Check {

	public static inline var DESC:String = "Check for explicit use of private in classes and public in interfaces/externs";

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
		if (f.access.indexOf(APublic) > -1) {
			_warnPublicKeyword(f.name, f.pos);
			return;
		}
	}

	function checkField(f:Field) {
		if (f.access.indexOf(APrivate) > -1) {
			_warnPrivateKeyword(f.name, f.pos);
			return;
		}
	}

	function _warnPrivateKeyword(name:String, pos:Position) {
		logPos('No need of private keyword \"${name}\" (fields are by default private in classes)', pos, SeverityLevel.INFO);
	}

	function _warnPublicKeyword(name:String, pos:Position) {
		logPos('No need of public keyword \"${name}\" (fields are by default public in interfaces)', pos, SeverityLevel.INFO);
	}
}