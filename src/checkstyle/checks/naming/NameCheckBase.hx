package checkstyle.checks.naming;

/**
	Base class for name checks
**/
@ignore("Base class for name checks")
class NameCheckBase<T> extends Check {
	/**
		regex name format
	**/
	public var format:String;

	/**
		list of tokens to limit where names should conform to "format"
	**/
	public var tokens:Array<T>;

	/**
		ignores names inside extern types
	**/
	public var ignoreExtern:Bool;

	var formatRE:EReg;

	public function new() {
		super(AST);
		format = "^.*$";
		tokens = [];
		ignoreExtern = true;
		categories = [Category.STYLE, Category.CLARITY];
	}

	function hasToken(token:T):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	override function actualRun() {
		formatRE = new EReg(format, "");
		checkClassFields();
	}

	function checkClassFields() {
		if (checker.ast == null) return;
		for (td in checker.ast.decls) {
			switch (td.decl) {
				case EClass(d):
					checkClassType(td.decl, d, td.pos);
				case EEnum(d):
					checkEnumType(td.decl, d, td.pos);
				case EAbstract(d):
					checkAbstractType(td.decl, d, td.pos);
				case ETypedef(d):
					checkTypedefType(td.decl, d, td.pos);
				default:
			}
		}
	}

	function checkClassType(decl:TypeDef, d:Definition<ClassFlag, Array<Field>>, pos:Position) {}

	function checkEnumType(decl:TypeDef, d:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position) {}

	function checkAbstractType(decl:TypeDef, d:Definition<AbstractFlag, Array<Field>>, pos:Position) {}

	function checkTypedefType(decl:TypeDef, d:Definition<EnumFlag, ComplexType>, pos:Position) {}

	function matchTypeName(type:String, name:String, pos:Position) {
		if (!formatRE.match(name)) {
			warn(type, name, pos);
		}
	}

	function warn(type:String, name:String, pos:Position) {
		logPos('Invalid ${type} signature: "${name}" (name should be "~/${format}/")', pos);
	}
}