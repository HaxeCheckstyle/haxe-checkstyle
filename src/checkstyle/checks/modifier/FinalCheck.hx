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

		if (checkInlineVar(f)) {
			logPos('Consider using "inline final" for field "${f.name}"', f.pos, USE_INLINE_FINAL);
			return;
		}
		if (checkPublicStatic(f)) {
			logPos('Consider making public static field "${f.name}" "final" or "private"', f.pos, SHOULD_BE_PUBLIC_FINAL);
			return;
		}
	}

	function checkPublicStatic(f:Field):Bool {
		return (f.access.contains(APublic)) && (f.access.contains(AStatic));
	}

	function checkInlineVar(f:Field):Bool {
		return (f.access.contains(AInline));
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

enum abstract FinalCode(String) to String {
	var USE_INLINE_FINAL = "UseInlineFinal";
	var SHOULD_BE_PUBLIC_FINAL = "ShouldBePublicFinal";
}
#end