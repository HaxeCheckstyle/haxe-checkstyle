package checkstyle.checks.naming;

/**
	Checks that type names conform to a format specified by the "format" property.
**/
@name("TypeName")
@desc("Checks that type names conform to a format specified by the `format` property.")
class TypeNameCheck extends NameCheckBase<TypeNameCheckToken> {
	public function new() {
		super();
		format = "^[A-Z]+[a-zA-Z0-9]*$";
	}

	override function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && d.flags.contains(HExtern)) return;

		var isInterface:Bool = (d.flags.contains(HInterface));

		if (!hasToken(INTERFACE) && isInterface) return;
		if (!hasToken(CLASS) && !isInterface) return;
		if (isInterface) {
			matchTypeName("interface", d.name, pos);
		}
		else {
			matchTypeName("class", d.name, pos);
		}
	}

	override function checkEnumType(decl:TypeDef, d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {
		if (!hasToken(ENUM)) return;
		if (ignoreExtern && d.flags.contains(EExtern)) return;

		matchTypeName("enum", d.name, pos);
	}

	override function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		if (!hasToken(ABSTRACT)) return;
		matchTypeName("abstract", d.name, pos);
	}

	override function checkTypedefType(decl:TypeDef, d:Definition<EnumFlag, ComplexType>, pos:Position) {
		if (!hasToken(TYPEDEF)) return;
		if (ignoreExtern && d.flags.contains(EExtern)) return;

		matchTypeName("typedef", d.name, pos);
	}
}

/**
	check applies to:
	- INTERFACE = all interface types
	- CLASS = all class types
	- ENUM = all enum types
	- ABSTRACT = all abstract types
	- TYPEDEF = all typedef types
**/
enum abstract TypeNameCheckToken(String) {
	var INTERFACE = "INTERFACE";
	var CLASS = "CLASS";
	var ENUM = "ENUM";
	var ABSTRACT = "ABSTRACT";
	var TYPEDEF = "TYPEDEF";
}