package checkstyle.checks.naming;

/**
	Checks that parameter names conform to a format specified by the "format" property.
**/
@name("ParameterName")
@desc("Checks that parameter names conform to a format specified by the `format` property.")
class ParameterNameCheck extends NameCheckBase<String> {
	public function new() {
		super();
		format = "^(_|[a-z][a-zA-Z0-9]*$)";
	}

	override function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && d.flags.contains(HExtern)) return;
		checkFields(d.data);
	}

	override function checkEnumType(decl:TypeDef, d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {
		if (ignoreExtern && d.flags.contains(EExtern)) return;
		checkEnumFields(d.data);
	}

	override function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		checkFields(d.data);
	}

	override function checkTypedefType(decl:TypeDef, d:Definition<EnumFlag, ComplexType>, pos:Position) {
		if (ignoreExtern && d.flags.contains(EExtern)) return;
		switch (d.data) {
			case TAnonymous(f):
				checkFields(f);
			default:
		}
	}

	function checkFields(d:Array<Field>) {
		for (field in d) {
			if (isCheckSuppressed(field)) continue;
			switch (field.kind) {
				case FFun(f):
					checkField(f.args, field.pos);
				default:
			}
		}
	}

	function checkEnumFields(d:Array<EnumConstructor>) {
		for (field in d) {
			for (arg in field.args) matchTypeName("parameter name", arg.name, field.pos);
		}
	}

	function checkField(args:Array<FunctionArg>, pos:Position) {
		if (args == null || args.length <= 0) return;
		for (arg in args) matchTypeName("parameter name", arg.name, pos);
	}
}