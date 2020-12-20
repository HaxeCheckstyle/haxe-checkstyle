package checkstyle.checks.naming;

/**
	Checks that instance variable names conform to a format specified by the "format" property.
**/
@name("MemberName")
@desc("Checks that instance variable names conform to a format specified by the `format` property.")
class MemberNameCheck extends NameCheckBase<MemberNameCheckToken> {
	public function new() {
		super();
		format = "^[a-z][a-zA-Z0-9]*$";
	}

	override function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (!hasToken(CLASS)) {
			// if ABSTRACT is set, PUBLIC and PRIVATE don't affect CLASS
			if (hasToken(ABSTRACT)) return;
			if (!hasToken(PUBLIC) && !hasToken(PRIVATE)) return;
		}
		if (ignoreExtern && d.flags.contains(HExtern)) return;
		checkFields(d.data, decl.toParentType());
	}

	override function checkEnumType(decl:TypeDef, d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {
		if (!hasToken(ENUM)) return;
		if (ignoreExtern && d.flags.contains(EExtern)) return;
		if (isPosSuppressed(pos)) return;
		checkEnumFields(d.data);
	}

	override function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		if (!hasToken(ABSTRACT)) {
			// if CLASS is set, PUBLIC and PRIVATE don't affect ABSTRACT
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
		if (hasToken(PUBLIC) || hasToken(PRIVATE)) {
			// with PUBLIC or PRIVATE set, only look at fields with matching access modifiers
			if (!hasToken(PUBLIC) && f.isPublic(p)) return;
			if (!hasToken(PRIVATE) && f.isPrivate(p)) return;
		}

		matchTypeName("member", f.name, f.pos);
	}

	function checkTypedefField(f:Field, t:ComplexType, e:Expr) {
		matchTypeName("typedef member", f.name, f.pos);
	}
}

/**
	check applies to:
	- PUBLIC = all public fields
	- PRIVATE = all private fields
	- ENUM = all enum fields
	- CLASS = all class fields, use in combination with PUBLIC and PRIVATE to only match public/private class fields
	- ABSTRACT = all abstract fields, use in combination with PUBLIC and PRIVATE to only match public/private abstract fields
	- TYPEDEF = all typedef fields
**/
enum abstract MemberNameCheckToken(String) {
	var PUBLIC = "PUBLIC";
	var PRIVATE = "PRIVATE";
	var ENUM = "ENUM";
	var CLASS = "CLASS";
	var ABSTRACT = "ABSTRACT";
	var TYPEDEF = "TYPEDEF";
}