package checkstyle.checks.modifier;

import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.ArrayUtils;
using checkstyle.utils.FieldUtils;

@name("RedundantModifier", "PublicPrivate")
@desc("Checks for redundant modifiers.")
class RedundantModifierCheck extends Check {

	public var enforcePublicPrivate:Bool;

	public function new() {
		super(AST);
		enforcePublicPrivate = false;
		categories = [Category.STYLE, Category.CLARITY];
		points = 1;
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, p:ParentType) {
		var isDefaultPrivate = f.isDefaultPrivate(p);
		var implicitAccess = isDefaultPrivate ? "private" : "public";
		if (enforcePublicPrivate) {
			if (!f.access.contains(APublic) && !f.access.contains(APrivate)) {
				logPos('Missing $implicitAccess keyword: ${f.name}', f.pos);
			}
		}
		else if ((isDefaultPrivate && f.access.contains(APrivate)) || (!isDefaultPrivate && f.access.contains(APublic))) {
			logPos('No need of $implicitAccess keyword: ${f.name}', f.pos);
		}
	}
}