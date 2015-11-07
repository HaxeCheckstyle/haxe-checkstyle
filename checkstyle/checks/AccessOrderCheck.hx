package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("AccessOrder")
@desc("Checks order of access modifiers")
class AccessOrderCheck extends Check {

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
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					checkFields(d);
				default:
			}
		}
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			if (isCheckSuppressed (field)) continue;
			checkField(field);
		}
	}

	function checkField(f:Field) {
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
		logPos('Invalid access modifier order: ${name} (modifier: ${modifier})', pos, Reflect.field(SeverityLevel, severity));
	}
}