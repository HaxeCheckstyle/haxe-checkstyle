package checkstyle.checks.modifier;

#if (haxe4)
/**
	Checks for places that use inline var instead of inline final (Haxe 4+)
**/
@name("InlineFinal")
@desc("Checks for places that use inline var instead of inline final (Haxe 4+).")
class InlineFinalCheck extends Check {
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