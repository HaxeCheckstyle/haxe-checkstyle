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
		var forcePrivate:Bool = enforcePrivate;
		var forcePublic:Bool = enforcePublic;
		if (enforcePublicPrivate) {
			forcePrivate = true;
			forcePublic = true;
		}
		forEachField(function(f:Field, p:ParentType) {
			checkField(f, p, forcePrivate, forcePublic);
		});
	}

	function checkField(f:Field, p:ParentType, forcePrivate:Bool, forcePublic:Bool) {
		var isDefaultPrivate = f.isDefaultPrivate(p);
		var implicitAccess = isDefaultPrivate ? "private" : "public";
		if (!f.access.contains(APublic) && !f.access.contains(APrivate)) {
			if ((!isDefaultPrivate && forcePublic) || (isDefaultPrivate && forcePrivate)) {
				logPos('Missing "$implicitAccess" keyword for "${f.name}"', f.pos);
			}
		}

		if ((!forcePrivate && isDefaultPrivate && f.access.contains(APrivate)) || (!forcePublic && !isDefaultPrivate && f.access.contains(APublic))) {
			logPos('"$implicitAccess" keyword is redundant for "${f.name}"', f.pos);
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "enforcePrivate",
				values: [true, false]
			},
			{
				propertyName: "enforcePublic",
				values: [true, false]
			},
			{
				propertyName: "enforcePublicPrivate",
				values: [true, false]
			}]
		}];
	}
}