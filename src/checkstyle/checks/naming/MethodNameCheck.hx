package checkstyle.checks.naming;

import haxe.rtti.CType.Typedef;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.FieldUtils;

@name("MethodName")
@desc("Checks the method names")
class MethodNameCheck extends NameCheckBase {

	public static inline var PUBLIC:String = "PUBLIC";
	public static inline var PRIVATE:String = "PRIVATE";
	public static inline var STATIC:String = "STATIC";
	public static inline var NOTSTATIC:String = "NOTSTATIC";
	public static inline var INLINE:String = "INLINE";
	public static inline var NOTINLINE:String = "NOTINLINE";

	public function new() {
		super();
		format = "^[a-z][a-zA-Z0-9]*$";
	}

	override function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && (d.flags.indexOf(HExtern) > -1)) return;
		if (d.flags.indexOf(HInterface) > -1) return;
		checkFields(d.data, decl.toParentType());
	}

	override function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		checkFields(d.data, decl.toParentType());
	}

	override function checkTypedefType(decl:TypeDef, d:Definition<EnumFlag, ComplexType>, pos:Position) {
		if (ignoreExtern && (d.flags.indexOf(EExtern) > -1)) return;

		var p = decl.toParentType();
		switch (d.data) {
			case TAnonymous(f):
				checkFields(f, p);
			default:
		}
	}

	function checkFields(d:Array<Field>, p:ParentType) {
		for (field in d) {
			if (isCheckSuppressed(field)) continue;
			switch (field.kind) {
				case FFun(f):
					checkField(field, p);
				default:
			}
		}
	}

	@SuppressWarnings('checkstyle:CyclomaticComplexity')
	function checkField(f:Field, p:ParentType) {
		if (f.isGetter() || f.isSetter()) return;
		if (hasToken(NOTINLINE) && !hasToken(INLINE) && f.isInline(p)) return;
		if (hasToken(INLINE) && !hasToken(NOTINLINE) && !f.isInline(p)) return;
		if (hasToken(NOTSTATIC) && !hasToken(STATIC) && f.isStatic(p)) return;
		if (hasToken(STATIC) && !hasToken(NOTSTATIC) && !f.isStatic(p)) return;
		if (hasToken(PUBLIC) && !hasToken(PRIVATE) && !f.isPublic(p)) return;
		if (hasToken(PRIVATE) && !hasToken(PUBLIC) && !f.isPrivate(p)) return;

		matchTypeName("method name", f.name, f.pos);
	}
}