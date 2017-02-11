package checkstyle.checks.modifier;

@name("RedundantModifier", "PublicPrivate")
@desc("Checks for redundant modifiers.")
class RedundantModifierCheck extends Check {

	public var enforcePublicPrivate:Bool;
	public var enforcePublic:Bool;
	public var enforcePrivate:Bool;

	public function new() {
		super(AST);
		enforcePublicPrivate = false;
		enforcePublic = false;
		enforcePrivate = false;
		categories = [Category.STYLE, Category.CLARITY];
		points = 1;
	}

	override function actualRun() {
		if (enforcePublicPrivate) {
			enforcePrivate = true;
			enforcePublic = true;
		}
		forEachField(checkField);
	}

	function checkField(f:Field, p:ParentType) {
		var isDefaultPrivate = f.isDefaultPrivate(p);
		var implicitAccess = isDefaultPrivate ? "private" : "public";
		if (!f.access.contains(APublic) && !f.access.contains(APrivate)) {
			if ((!isDefaultPrivate && enforcePublic) || (isDefaultPrivate && enforcePrivate)) {
				logPos('Missing "$implicitAccess" keyword for "${f.name}"', f.pos);
			}
		}

		if ((!enforcePrivate && isDefaultPrivate && f.access.contains(APrivate)) || (!enforcePublic && !isDefaultPrivate && f.access.contains(APublic))) {
			logPos('"$implicitAccess" keyword is redundant for "${f.name}"', f.pos);
		}
	}
}