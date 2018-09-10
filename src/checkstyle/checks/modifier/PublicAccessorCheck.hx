package checkstyle.checks.modifier;

/**
	Checks for public accessors.
**/
@name("PublicAccessor")
@desc("Checks for public accessors.")
class PublicAccessorCheck extends Check {
	public function new() {
		super(AST);
		categories = [Category.STYLE, Category.CLARITY];
		points = 1;
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, p:ParentType) {
		if (!f.kind.match(FFun(_))) return;
		if (!f.name.startsWith("set_") && !f.name.startsWith("get_")) return;

		var isDefaultPrivate = f.isDefaultPrivate(p);
		if (isDefaultPrivate && !f.access.contains(APublic)) return;
		else if (!isDefaultPrivate && f.access.contains(APrivate)) return;

		logPos("Accessor method should not be public", f.pos);
	}
}