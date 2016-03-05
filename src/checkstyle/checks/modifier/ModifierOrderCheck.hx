package checkstyle.checks.modifier;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("ModifierOrder", "AccessOrder")
@desc("Checks order of modifiers")
class ModifierOrderCheck extends Check {

	public static inline var PUBLIC_PRIVATE:String = "PUBLIC_PRIVATE";
	public static inline var INLINE:String = "INLINE";
	public static inline var STATIC:String = "STATIC";
	public static inline var OVERRIDE:String = "OVERRIDE";
	public static inline var MACRO:String = "MACRO";
	public static inline var DYNAMIC:String = "DYNAMIC";

	public var modifiers:Array<String>;

	public function new() {
		super();
		modifiers = [
			MACRO,
			OVERRIDE,
			PUBLIC_PRIVATE,
			STATIC,
			INLINE,
			DYNAMIC
		];
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, _) {
		var lastIndex:Int = -1;
		var index:Int;

		for (access in f.access) {
			var modifier:String = mapAccessModifier(access);
			index = modifiers.indexOf(modifier);
			if (index < lastIndex) {
				warnOrder(f.name, modifier, f.pos);
				return;
			}
			lastIndex = index;
		}
	}

	function mapAccessModifier(access:Access):String {
		return switch (access) {
			case APublic, APrivate:
				PUBLIC_PRIVATE;
			case AStatic:
				STATIC;
			case AInline:
				INLINE;
			case AOverride:
				OVERRIDE;
			case AMacro:
				MACRO;
			case ADynamic:
				DYNAMIC;
		}
	}

	function warnOrder(name:String, modifier:String, pos:Position) {
		logPos('Invalid modifier order: ${name} (modifier: ${modifier})', pos, severity);
	}
}