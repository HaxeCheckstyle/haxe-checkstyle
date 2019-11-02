package checkstyle.checks.modifier;

#if (haxe4)
/**
	Checks for places that use var instead of final (Haxe 4+).
**/
@name("Final", "InlineFinal")
@desc("Checks for places that use var instead of final (Haxe 4+).")
class FinalCheck extends Check {
	public function new() {
		super(AST);
		categories = [Category.STYLE, Category.CLARITY];
		points = 1;
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, p:ParentType) {
		switch (f.kind) {
			case FVar(_):
			case FFun(_):
				return;
			case FProp(_):
				return;
		}
		if (f.access.contains(AFinal)) return;

		checkPublicStatic(f);
		checkInlineVar(f);
	}

	function checkPublicStatic(f:Field) {
		if (!f.access.contains(APublic)) return;
		if (!f.access.contains(AStatic)) return;

		logPos('Consider using "final" for field "${f.name}"', f.pos);
	}

	function checkInlineVar(f:Field) {
		if (!f.access.contains(AInline)) return;
		logPos('Consider using "inline final" for field "${f.name}"', f.pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.INFO]
			}]
		}];
	}
}
#end