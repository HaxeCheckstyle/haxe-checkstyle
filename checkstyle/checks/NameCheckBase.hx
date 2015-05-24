package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@ignore("Base class for name checks")
class NameCheckBase extends Check {

	public var severity:String;
	public var format:String;
	public var tokens:Array<String>;
	public var ignoreExtern:Bool;

	var formatRE:EReg;

	public function new() {
		super();
		severity = "ERROR";
		format = "^.*$";
		tokens = [];
		ignoreExtern = true;
	}

	function hasToken(token:String):Bool {
		if (tokens.length == 0) return true;
		if (tokens.indexOf (token) > -1) return true;
		return false;
	}

	override function _actualRun() {
		formatRE = new EReg (format, "");
		checkClassFields();
	}

	function checkClassFields() {
		for (td in _checker.ast.decls) {
			switch (td.decl) {
				case EClass (d):
					checkClassType (d, td.pos);
				case EEnum (d):
					checkEnumType (d, td.pos);
				case EAbstract (d):
					checkAbstractType (d, td.pos);
				case ETypedef (d):
					checkTypedefType (d, td.pos);
				default:
			}
		}
	}

	function checkClassType(d:Definition<ClassFlag, Array<Field>>, pos:Position) {}

	function checkEnumType(d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {}

	function checkAbstractType(d:Definition<AbstractFlag, Array<Field>>, pos:Position) {}

	function checkTypedefType(d:Definition<EnumFlag, ComplexType>, pos:Position) {}

	function getFieldAccess(f:Field):NameFieldAccess {
		var isPrivate = false;
		var isPublic = false;
		var isInline = false;
		var isStatic = false;

		if (f.access.indexOf(AInline) > -1) isInline = true;
		if (f.access.indexOf(AStatic) > -1) isStatic = true;
		if (f.access.indexOf(APublic) > -1) isPublic = true;
		else isPrivate = true;
		return {
			isPrivate: isPrivate,
			isPublic: isPublic,
			isInline: isInline,
			isStatic: isStatic
		};
	}

	function matchTypeName(type:String, name:String, pos:Position)
	{
		if (!formatRE.match (name)) {
			_warn(type, name, pos);
		}
	}

	function _warn(type:String, name:String, pos:Position) {
		logPos('Invalid ${type} signature: ${name} (name should be ~/${format}/)', pos, Reflect.field(SeverityLevel, severity));
	}
}

typedef NameFieldAccess = {
	var isPrivate:Bool;
	var isPublic:Bool;
	var isInline:Bool;
	var isStatic:Bool;
};
