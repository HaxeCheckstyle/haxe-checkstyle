package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("ConstantName")
@desc("Checks on naming conventions of constants (static / static inline with initialisation)")
class ConstantNameCheck extends NameCheckBase {

	public static inline var INLINE:String = "INLINE";
	public static inline var NOTINLINE:String = "NOTINLINE";

	public function new() {
		super();
		format = "^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$";
	}

	override function checkClassType(d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && (d.flags.indexOf (HExtern) > -1)) return;
		checkFields (d.data);
	}

	override function checkEnumType(d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {}

	override function checkAbstractType(d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		checkFields (d.data);
	}

	override function checkTypedefType(d:Definition<EnumFlag, ComplexType>, pos:Position) {}

	function checkFields(d:Array<Field>) {
		for (field in d) {
			if (isCheckSuppressed (field)) continue;
			switch (field.kind) {
				case FVar (t, e):
					checkField(field, t, e);
				default:
			}
		}
	}

	function checkField(f:Field, t:ComplexType, e:Expr) {

		if (e == null || e.expr == null) return;
		var access = getFieldAccess (f);

		if (!access.isStatic) return;
		if (!hasToken (INLINE) && access.isInline) return;
		if (!hasToken (NOTINLINE) && !access.isInline) return;

		matchTypeName ("const", f.name, f.pos);
	}
}
