package checkstyle.checks.modifier;

import haxeparser.Data;
import haxe.macro.Expr;

@name("ModifierOrder", "AccessOrder")
@desc("Checks order of modifiers")
class ModifierOrderCheck extends Check {

	public var modifiers:Array<ModifierOrderCheckModifier>;

	public function new() {
		super(AST);
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
			var modifier:ModifierOrderCheckModifier = access;
			index = modifiers.indexOf(modifier);
			if (index < lastIndex) {
				warnOrder(f.name, modifier, f.pos);
				return;
			}
			lastIndex = index;
		}
	}

	function warnOrder(name:String, modifier:ModifierOrderCheckModifier, pos:Position) {
		logPos('Invalid modifier order: ${name} (modifier: ${modifier})', pos);
	}
}

@:enum
abstract ModifierOrderCheckModifier(String) {
	var PUBLIC_PRIVATE = "PUBLIC_PRIVATE";
	var INLINE = "INLINE";
	var STATIC = "STATIC";
	var OVERRIDE = "OVERRIDE";
	var MACRO = "MACRO";
	var DYNAMIC = "DYNAMIC";

	@:from
	public static function fromAccess(access:Access):ModifierOrderCheckModifier {
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
}