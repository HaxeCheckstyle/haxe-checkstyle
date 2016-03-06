package checkstyle.checks.modifier;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.FieldUtils;

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
			if (!field.isConstructor()) {
				if (parent.kind == INTERFACE) checkInterfaceField(field, parent);
				else checkField(field, parent);
			}
		});
	}

	function checkInterfaceField(f:Field, p:ParentType) {
		if (enforcePublicPrivate) {
			if (!f.hasPublic()) {
				logPos('Missing public keyword: ${f.name}', f.pos, severity);
			}
		}
		else {
			if (f.hasPublic()) {
				logPos('No need of public keyword: ${f.name} (fields are by default public in interfaces)', f.pos, severity);
			}
		}
	}

	function checkField(f:Field, p:ParentType) {
		if (enforcePublicPrivate) {
			if (!f.hasPublic() && !f.hasPrivate()) {
				logPos('Missing private keyword: ${f.name}', f.pos, severity);
			}
		}
		else {
			if (f.hasPrivate()) {
				logPos('No need of private keyword: ${f.name} (fields are by default private in classes)', f.pos, severity);
			}
		}
	}
}