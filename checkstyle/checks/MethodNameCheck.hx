package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("MethodName")
@desc("Checks on naming conventions of methods")
class MethodNameCheck extends NameCheckBase {

	public static inline var PUBLIC:String = "PUBLIC";
	public static inline var PRIVATE:String = "PRIVATE";
	public static inline var STATIC:String = "STATIC";
	public static inline var NOTSTATIC:String = "NOTSTATIC";
	public static inline var INLINE:String = "INLINE";
	public static inline var NOTINLINE:String = "NOTINLINE";

	public function new() {
		super();
		severity = "ERROR";
		format = "^[a-z]+[a-zA-Z0-9_]*$";
	}

	override function checkClassType(d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && (d.flags.indexOf (HExtern) > -1)) return;
		checkFields (d.data);
	}

	override function checkEnumType(d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {}

	override function checkAbstractType(d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		checkFields (d.data);
	}

	override function checkTypedefType(d:Definition<EnumFlag, ComplexType>, pos:Position) {
		if (ignoreExtern && (d.flags.indexOf (EExtern) > -1)) return;

		switch (d.data) {
			case TAnonymous (f):
				checkFields (f);
			default:
		}
	}

	function checkFields(d:Array<Field>) {
		for (field in d) {
			switch (field.kind) {
				case FFun (f):
					checkField (field);
				default:
			}
		}
	}

	function checkField(f:Field) {

		var getter = StringTools.startsWith (f.name, "get_");
		var setter = StringTools.startsWith (f.name, "set_");

		if (getter || setter) return;

		var access = getFieldAccess (f);
		if (hasToken (NOTINLINE) && !hasToken (INLINE)    && access.isInline) return;
		if (hasToken (INLINE)    && !hasToken (NOTINLINE) && !access.isInline) return;
		if (hasToken (NOTSTATIC) && !hasToken (STATIC)    && access.isStatic) return;
		if (hasToken (STATIC)    && !hasToken (NOTSTATIC) && !access.isStatic) return;
		if (hasToken (PUBLIC)    && !hasToken (PRIVATE)   && !access.isPublic) return;
		if (hasToken (PRIVATE)   && !hasToken (PUBLIC)    && !access.isPrivate) return;

		matchTypeName ("method name", f.name, f.pos);
	}
}
