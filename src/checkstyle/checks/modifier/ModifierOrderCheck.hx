package checkstyle.checks.modifier;

import haxe.macro.PositionTools;

/**
	Checks that the order of modifiers conforms to the standards.
**/
@name("ModifierOrder", "AccessOrder")
@desc("Checks that the order of modifiers conforms to the standards.")
class ModifierOrderCheck extends Check {
	/**
		order in which modifier should occur
	**/
	public var modifiers:Array<ModifierOrderCheckModifier>;

	public function new() {
		super(AST);
		modifiers = [MACRO, OVERRIDE, PUBLIC_PRIVATE, STATIC, INLINE, DYNAMIC, FINAL];
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		forEachField(checkField);
	}

	function checkField(f:Field, _) {
		var lastIndex:Int = -1;
		var index:Int;

		var actual:Array<String> = [];
		var expected:Array<String> = [];
		expected.resize(modifiers.length);

		var compliant:Bool = true;

		for (access in f.access) {
			var modifier:ModifierOrderCheckModifier = access;
			index = modifiers.indexOf(modifier);
			if (index < 0) continue;
			actual.push(ModifierOrderCheckModifier.accessToString(access));
			expected[index] = ModifierOrderCheckModifier.accessToString(access);
			if (index < lastIndex) {
				compliant = false;
			}
			lastIndex = index;
		}
		if (compliant) return;
		var pos = calcPos(f);
		warnOrder(f.name, actual, expected, pos);
	}

	function calcPos(f:Field):Position {
		switch (f.kind) {
			case FVar(_, _), FProp(_, _, _, _):
				return f.pos;
			case FFun(fun):
				if (fun.expr == null) {
					return f.pos;
				}
				return PositionTools.make({min: f.pos.min, max: fun.expr.pos.min, file: f.pos.file});
		}
	}

	function warnOrder(name:String, actual:Array<String>, expected:Array<String>, pos:Position) {
		expected = expected.filter(function(f:String):Bool return (f != null));
		logPos('modifier order for field "${name}" is "${actual.join(" ")}" but should be "${expected.join(" ")}"', pos);
	}
}

/**
	list of modifiers
	- PUBLIC_PRIVATE = public / private modifier
	- INLINE = inline modifier
	- STATIC = static modifier
	- OVERRIDE = override modifier
	- MACRO = macro modifier
	- DYNAMIC = dynamic modifier
	- EXTERN = extern modifier
	- FINAL = final modifier
**/
enum abstract ModifierOrderCheckModifier(String) {
	var PUBLIC_PRIVATE = "PUBLIC_PRIVATE";
	var INLINE = "INLINE";
	var STATIC = "STATIC";
	var OVERRIDE = "OVERRIDE";
	var MACRO = "MACRO";
	var DYNAMIC = "DYNAMIC";
	var EXTERN = "EXTERN";
	var FINAL = "FINAL";
	var ABSTRACT = "ABSTRACT";
	var OVERLOAD = "OVERLOAD";

	@:from
	public static function fromAccess(access:Access):ModifierOrderCheckModifier {
		return switch (access) {
			case APublic, APrivate: PUBLIC_PRIVATE;
			case AStatic: STATIC;
			case AInline: INLINE;
			case AOverride: OVERRIDE;
			case AMacro: MACRO;
			case ADynamic: DYNAMIC;
			case AExtern: EXTERN;
			case AFinal: FINAL;
			#if (haxe >= version("4.2.0-rc.1"))
			case AAbstract: ABSTRACT;
			case AOverload: OVERLOAD;
			#end
		}
	}

	public static function accessToString(access:Access):String {
		return switch (access) {
			case APublic: "public";
			case APrivate: "private";
			case AStatic: "static";
			case AInline: "inline";
			case AOverride: "override";
			case AMacro: "macro";
			case ADynamic: "dynamic";
			case AExtern: "extern";
			case AFinal: "final";
			#if (haxe >= version("4.2.0-rc.1"))
			case AAbstract: "abstract";
			case AOverload: "overload";
			#end
		}
	}
}