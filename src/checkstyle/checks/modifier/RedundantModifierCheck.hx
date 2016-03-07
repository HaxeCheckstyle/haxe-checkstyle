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
		super(AST);
		enforcePublicPrivate = false;
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, p:ParentType) {
		var isDefaultPrivate = f.isDefaultPrivate(p);
		var implicitAccess = isDefaultPrivate ? "private" : "public";
		if (enforcePublicPrivate) {
			if (!f.hasPublic() && !f.hasPrivate()) {
				logPos('Missing $implicitAccess keyword: ${f.name}', f.pos, severity);
			}
		}
		else if ((isDefaultPrivate && f.hasPrivate()) || (!isDefaultPrivate && f.hasPublic())) {
			logPos('No need of $implicitAccess keyword: ${f.name}', f.pos, severity);
		}
	}
}