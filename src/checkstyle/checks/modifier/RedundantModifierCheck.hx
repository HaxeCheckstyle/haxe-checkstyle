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
				checkField(field, parent);
			}
		});
	}

	@SuppressWarnings('checkstyle:AvoidInlineConditionals')
	function checkField(f:Field, p:ParentType) {
		var isDefaultPrivate = f.isDefaultPrivate(p);
		var implicitKeyword = isDefaultPrivate ? "private" : "public";
		if (enforcePublicPrivate) {
			if (!f.hasPublic() && !f.hasPrivate()) {
				logPos('Missing $implicitKeyword keyword: ${f.name}', f.pos, severity);
			}
		}
		else {
			var redundantKeyword = isDefaultPrivate ? "private" : "public";
			if ((isDefaultPrivate && f.hasPrivate()) || (!isDefaultPrivate && f.hasPublic())) {
				logPos('No need of $implicitKeyword keyword: ${f.name}', f.pos, severity);
			}
		}
	}
}