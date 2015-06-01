package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("MemberName")
@desc("Checks on naming conventions of non-static fields")
class MemberNameCheck extends NameCheckBase {

	public static inline var PUBLIC:String = "PUBLIC";
	public static inline var PRIVATE:String = "PRIVATE";
	public static inline var ENUM:String = "ENUM";
	public static inline var TYPEDEF:String = "TYPEDEF";

	public function new() {
		super();
		format = "^[a-z]+[a-zA-Z0-9]*$";
	}

	override function checkClassType(d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && (d.flags.indexOf(HExtern) > -1)) return;
		checkFields(d.data);
	}

	override function checkEnumType(d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {
		if (!hasToken(ENUM)) return;
		if (ignoreExtern && (d.flags.indexOf(EExtern) > -1)) return;
		checkEnumFields(d.data);
	}

	override function checkAbstractType(d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		checkFields(d.data);
	}

	@SuppressWarnings('checkstyle:Anonymous')
	override function checkTypedefType(d:Definition<EnumFlag, ComplexType>, pos:Position) {
		if (!hasToken(TYPEDEF)) return;
		if (ignoreExtern && (d.flags.indexOf(EExtern) > -1)) return;

		switch (d.data) {
			case TAnonymous(f):
				checkTypedefFields(f);
			default:
		}
	}

	function checkFields(d:Array<Field>) {
		for (field in d) {
			if (isCheckSuppressed(field)) continue;
			switch (field.kind) {
				case FVar(t, e):
					checkField(field, t, e);
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
		for (field in d) {
			matchTypeName("enum member", field.name, field.pos);
		}
	}

	function checkField(f:Field, t:ComplexType, e:Expr) {
		var access = getFieldAccess(f);

		if (access.isStatic) return;
		if (!hasToken(PUBLIC) && access.isPublic) return;
		if (!hasToken(PRIVATE) && access.isPrivate) return;

		matchTypeName("member", f.name, f.pos);
	}

	function checkTypedefField(f:Field, t:ComplexType, e:Expr) {
		matchTypeName("typedef member", f.name, f.pos);
	}
}