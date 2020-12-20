package checkstyle.checks.naming;

import checkstyle.detect.DetectableInstance;

/**
	Checks that the constants (static / static inline with initialisation) conform to a format specified by the "format" property.
**/
@name("ConstantName")
@desc("Checks that the constants (static / static inline with initialisation) conform to a format specified by the `format` property.")
class ConstantNameCheck extends NameCheckBase<ConstantNameCheckToken> {
	public function new() {
		super();
		format = UPPER_CASE;
	}

	override function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {
		if (ignoreExtern && (d.flags.contains(HExtern))) return;
		checkFields(d.data, decl.toParentType());
	}

	override function checkEnumType(decl:TypeDef, d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {}

	override function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {
		checkFields(d.data, decl.toParentType());
	}

	override function checkTypedefType(decl:TypeDef, d:Definition<EnumFlag, ComplexType>, pos:Position) {}

	function checkFields(d:Array<Field>, p:ParentType) {
		for (field in d) {
			if (isCheckSuppressed(field)) continue;
			switch (field.kind) {
				case FVar(t, e):
					checkField(field, t, e, p);
				default:
			}
		}
	}

	function checkField(f:Field, t:ComplexType, e:Expr, p:ParentType) {
		if (e == null || e.expr == null || !f.isStatic(p)) return;
		if (!hasToken(INLINE) && f.isInline(p)) return;
		if (!hasToken(NOTINLINE) && !f.isInline(p)) return;

		matchTypeName("const", f.name, f.pos);
	}

	override public function detectableInstances():DetectableInstances {
		var instanceInline:DetectableInstance = {
			fixed: [{
				propertyName: "tokens",
				value: [INLINE]
			}],
			properties: [{
				propertyName: "format",
				values: [UPPER_CASE, CAMEL_CASE, LOWER_CASE]
			}, {
				propertyName: "ignoreExtern",
				values: [true, false]
			}]
		};
		var instanceNotInline:DetectableInstance = {
			fixed: [{
				propertyName: "tokens",
				value: [NOTINLINE]
			}],
			properties: [{
				propertyName: "format",
				values: [UPPER_CASE, CAMEL_CASE, LOWER_CASE]
			}, {
				propertyName: "ignoreExtern",
				values: [true, false]
			}]
		}
		return [instanceInline, instanceNotInline];
	}
}

/**
	supports inline and non inline constants
	- INLINE = "static inline var"
	- NOTINLINE = "static var"
**/
enum abstract ConstantNameCheckToken(String) {
	var INLINE = "INLINE";
	var NOTINLINE = "NOTINLINE";
}

enum abstract ConstantNameCheckFormt(String) to String {
	var UPPER_CASE = "^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$";
	var CAMEL_CASE = "^[A-Z]+[a-zA-Z0-9]*$";
	var LOWER_CASE = "^[a-z][a-zA-Z0-9]*$";
}