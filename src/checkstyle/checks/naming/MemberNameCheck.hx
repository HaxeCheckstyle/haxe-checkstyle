package checkstyle.checks.naming;

@name("MemberName")
@desc("Checks that instance variable names conform to a format specified by the `format` property.")
class MemberNameCheck extends NameCheckBase<MemberNameCheckToken> {

	public function new() {
		super();
		format = "^[a-z][a-zA-Z0-9]*$";
	}

	override function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (!hasToken(CLASS)) {
			if (hasToken(ABSTRACT)) return;
			if (!hasToken(PUBLIC) && !hasToken(PRIVATE)) return;
		}
		if (ignoreExtern && d.flags.contains(HExtern)) return;
		checkFields(d.data, decl.toParentType());
	}

	override function checkEnumType(decl:TypeDef, d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {
		if (!hasToken(ENUM)) return;
		if (ignoreExtern && d.flags.contains(EExtern)) return;
		if (!hasSuppressWarningsMeta(d.meta)) checkEnumFields(d.data);
	}

	override function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		if (!hasToken(ABSTRACT)) {
			if (hasToken(CLASS)) return;
			if (!hasToken(PUBLIC) && !hasToken(PRIVATE)) return;
		}
		checkFields(d.data, decl.toParentType());
	}

	override function checkTypedefType(decl:TypeDef, d:Definition<EnumFlag, ComplexType>, pos:Position) {
		if (!hasToken(TYPEDEF)) return;
		if (ignoreExtern && d.flags.contains(EExtern)) return;

		switch (d.data) {
			case TAnonymous(f):
				checkTypedefFields(f);
			default:
		}
	}

	function checkFields(d:Array<Field>, p:ParentType) {
		for (field in d) {
			if (isCheckSuppressed(field)) continue;
			switch (field.kind) {
				case FVar(t, e):
					checkField(field, t, e, p);
				case FProp(_, _, t, e):
					checkField(field, t, e, p);
				default:
			}
		}
	}

	function checkTypedefFields(d:Array<Field>) {
		for (field in d) {
			if (isCheckSuppressed(field)) continue;
			switch (field.kind) {
				case FVar(t, e):
					checkTypedefField(field, t, e);
				default:
			}
		}
	}

	function checkEnumFields(d:Array<EnumConstructor>) {
		for (field in d) matchTypeName("enum member", field.name, field.pos);
	}

	function checkField(f:Field, t:ComplexType, e:Expr, p:ParentType) {
		if (f.isStatic(p)) return;
		if (!hasToken(PUBLIC) && f.isPublic(p)) return;
		if (!hasToken(PRIVATE) && f.isPrivate(p)) return;

		matchTypeName("member", f.name, f.pos);
	}

	function checkTypedefField(f:Field, t:ComplexType, e:Expr) {
		matchTypeName("typedef member", f.name, f.pos);
	}
}

@:enum
abstract MemberNameCheckToken(String) {
	var PUBLIC = "PUBLIC";
	var PRIVATE = "PRIVATE";
	var ENUM = "ENUM";
	var CLASS = "CLASS";
	var ABSTRACT = "ABSTRACT";
	var TYPEDEF = "TYPEDEF";
}