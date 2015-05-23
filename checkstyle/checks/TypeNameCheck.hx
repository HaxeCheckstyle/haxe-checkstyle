package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("TypeName")
@desc("Checks on naming conventions of types (classes, interfaces, enums, typedefs)")
class TypeNameCheck extends NameCheckBase {

	public static inline var INTERFACE:String = "INTERFACE";
	public static inline var CLAZZ:String = "CLASS";
	public static inline var ENUM:String = "ENUM";
	public static inline var ABSTRACT:String = "ABSTRACT";
	public static inline var TYPEDEF:String = "TYPEDEF";

	public function new() {
		super();
		severity = "ERROR";
		format = "^[A-Z]+[a-zA-Z0-9_]*$";
	}

	override function checkClassType(d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && (d.flags.indexOf (HExtern) > -1)) return;

		var isInterface:Bool = (d.flags.indexOf (HInterface) > -1);

		if (!hasToken (INTERFACE) && isInterface) return;
		if (!hasToken (CLAZZ) && !isInterface) return;
		if (isInterface)
		{
			matchTypeName ("interface", d.name, pos);
		}
		else
		{
			matchTypeName ("class", d.name, pos);
		}
	}

	override function checkEnumType(d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {
		if (!hasToken (ENUM)) return;
		if (ignoreExtern && (d.flags.indexOf (EExtern) > -1)) return;

		matchTypeName ("enum", d.name, pos);
	}

	override function checkAbstractType(d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		if (!hasToken (ABSTRACT)) return;
		matchTypeName ("abstract", d.name, pos);
	}

	override function checkTypedefType(d:Definition<EnumFlag, ComplexType>, pos:Position) {
		if (!hasToken (TYPEDEF)) return;
		if (ignoreExtern && (d.flags.indexOf (EExtern) > -1)) return;

		matchTypeName ("typedef", d.name, pos);
	}
}
