package checkstyle.checks.naming;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.FieldUtils;

@name("ConstantName")
@desc("Checks on naming conventions of constants (static / static inline with initialisation)")
class ConstantNameCheck extends NameCheckBase {

	public static inline var INLINE:String = "INLINE";
	public static inline var NOTINLINE:String = "NOTINLINE";

	public function new() {
		super();
		format = "^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$";
	}

	override function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && (d.flags.indexOf (HExtern) > -1)) return;
		checkFields(d.data, decl.toParentType());
	}

	override function checkEnumType(decl:TypeDef, d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {}

	override function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		checkFields(d.data, decl.toParentType());
	}

	override function checkTypedefType(decl:TypeDef, d:Definition<EnumFlag, ComplexType>, pos:Position) {}

	function checkFields(d:Array<Field>, p:ParentType) {
		for (field in d) {
			if (isCheckSuppressed (field)) continue;
			switch (field.kind) {
				case FVar (t, e):
					checkField(field, t, e, p);
				default:
			}
		}
	}

	function checkField(f:Field, t:ComplexType, e:Expr, p:ParentType) {

		if (e == null || e.expr == null) return;

		if (!f.isStatic(p)) return;
		if (!hasToken (INLINE) && f.isInline(p)) return;
		if (!hasToken (NOTINLINE) && !f.isInline(p)) return;

		matchTypeName ("const", f.name, f.pos);
	}
}