package checkstyle.checks.modifier;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("RedundantModifier", "PublicPrivate")
@desc("Checks for redundant modifiers")
class RedundantModifierCheck extends Check {

	public var enforcePublicPrivate:Bool;

	public function new() {
		super();
		enforcePublicPrivate = false;
	}

	override function actualRun() {
		forEachField(function(field, parent) {
			if (field.name != "new") {
				if (parent.kind == INTERFACE) checkInterfaceField(field);
				else checkField(field);
			}
		});
	}

	function checkInterfaceField(f:Field) {
		if (enforcePublicPrivate) {
			if (f.access.indexOf(APublic) < 0) {
				logPos('Missing public keyword: ${f.name}', f.pos, severity);
			}
		}
		else {
			if (f.access.indexOf(APublic) > -1) {
				logPos('No need of public keyword: ${f.name} (fields are by default public in interfaces)', f.pos, severity);
			}
		}
	}

	function checkField(f:Field) {
		if (enforcePublicPrivate) {
			if ((f.access.indexOf(APublic) < 0) && (f.access.indexOf(APrivate) < 0)) {
				logPos('Missing private keyword: ${f.name}', f.pos, severity);
			}
		}
		else {
			if (f.access.indexOf(APrivate) > -1) {
				logPos('No need of private keyword: ${f.name} (fields are by default private in classes)', f.pos, severity);
			}
		}
	}
}