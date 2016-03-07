package checkstyle.checks.naming;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@ignore("Base class for name checks")
class NameCheckBase<T> extends Check {

	public var format:String;
	public var tokens:Array<T>;
	public var ignoreExtern:Bool;

	var formatRE:EReg;

	public function new() {
		super(AST);
		format = "^.*$";
		tokens = [];
		ignoreExtern = true;
	}

	function hasToken(token:T):Bool {
		return (tokens.length == 0 || tokens.indexOf(token) > -1);
	}

	override function actualRun() {
		formatRE = new EReg (format, "");
		checkClassFields();
	}

	function checkClassFields() {
		for (td in checker.ast.decls) {
			switch (td.decl) {
				case EClass (d):
					checkClassType (td.decl, d, td.pos);
				case EEnum (d):
					checkEnumType (td.decl, d, td.pos);
				case EAbstract (d):
					checkAbstractType (td.decl, d, td.pos);
				case ETypedef (d):
					checkTypedefType (td.decl, d, td.pos);
				default:
			}
		}
	}

	function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {}

	function checkEnumType(decl:TypeDef, d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {}

	function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {}

	function checkTypedefType(decl:TypeDef, d:Definition<EnumFlag, ComplexType>, pos:Position) {}

	function matchTypeName(type:String, name:String, pos:Position) {
		if (!formatRE.match (name)) {
			warn(type, name, pos);
		}
	}

	function warn(type:String, name:String, pos:Position) {
		logPos('Invalid ${type} signature: ${name} (name should be ~/${format}/)', pos, severity);
	}
}