package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Naming")
class NamingCheck extends Check {
	public function new() {
		super();
	}

	var privateCamelCaseRE = ~/^_?[a-z0-9_]*$/i;
	var publicCamelCaseRE = ~/^[a-z0-9_]*$/i;
	var bigCamelCaseRE = ~/^_?[A-Z]\w*$/;
	var capsRE = ~/^_?[A-Z][A-Z0-9_]*$/;

	override function actualRun() {
		checkClassFields();
		checkLocalVars();
	}

	function checkClassFields() {
		for (td in _checker.ast.decls) {
			switch (td.decl){
				case EClass(d):
					checkFields(d);
				default:
			}
		}
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			if (field.name != "new") {
				if (d.flags.indexOf(HInterface) > -1) checkInterfaceField(field);
				else checkField(field);
			}
		}
	}

	function checkInterfaceField(f:Field) {
		var isPrivate = false;
		var isPublic = false;
		var isInline = false;
		var isStatic = false;

		if (f.access.indexOf(AInline) > -1) isInline = true;
		else if (f.access.indexOf(AStatic) > -1) isStatic = true;
		else if (f.access.indexOf(APrivate) > -1) isPrivate = true;
		else if (f.access.indexOf(APublic) > -1) {
			_warnPublicKeyword(f.name, f.pos);
			return;
		}
		else isPublic = true;

		_genericCheck(isInline, isPrivate, isPublic, isStatic, f);
	}

	function checkField(f:Field) {
		var isPrivate = false;
		var isPublic = false;
		var isInline = false;
		var isStatic = false;

		if (f.access.indexOf(AInline) > -1) isInline = true;
		else if (f.access.indexOf(AStatic) > -1) isStatic = true;
		else if (f.access.indexOf(APublic) > -1) isPublic = true;
		else if (f.access.indexOf(APrivate) > -1) {
			_warnPrivateKeyword(f.name, f.pos);
			return;
		}
		else isPrivate = true;

		if (Std.string(f.kind).indexOf("ret => TPath({ name => Void") > -1) {
			_warnVoid(f.name, f.pos);
		}

		_genericCheck(isInline, isPrivate, isPublic, isStatic, f);
		//trace(f.name, Std.string(f.kind).indexOf("FVar"), Std.string(f.kind).indexOf("expr => "));
	}

	function _genericCheck(isInline:Bool, isPrivate:Bool, isPublic:Bool, isStatic:Bool, f:Field) {
		//trace(Std.string(f.kind));

		if (Std.string(f.kind).indexOf("expr => EReturn") > -1 && Std.string(f.kind).indexOf("ret => null") > -1) {
			_warnNoReturnType(f.name, f.pos);
		}

		if (isPrivate || isPublic) {
			var underscore:Int = f.name.lastIndexOf("_");
			var set:Int = f.name.indexOf("set_");
			var get:Int = f.name.indexOf("get_");
			if (isPrivate && (!privateCamelCaseRE.match(f.name) || underscore == -1 || (underscore > 0 && set == -1 && get == -1) || underscore > 3 || (underscore > 0 && underscore < 3))) {
				_warnPrivate(f.name, f.pos);
				return;
			}
			else if (isPublic && (!publicCamelCaseRE.match(f.name) || (underscore > -1 && set == -1 && get == -1) || underscore > 3 || (underscore > -1 && underscore < 3))) {
				_warnPublic(f.name, f.pos);
				return;
			}

			if (Std.string(f.kind).indexOf("FVar") > -1 && Std.string(f.kind).indexOf("expr =>") > -1) {
				_warnVarinit(f.name, f.pos);
				return;
			}
		}
		else if (isInline && Std.string(f.kind).indexOf("FVar") > -1) {
			if(!capsRE.match(f.name)) {
				_warnInline(f.name, f.pos);
				return;
			}
		}
		else if (isStatic) {

		}
	}

	function checkLocalVars() {
		ExprUtils.walkFile(_checker.ast, function(e) {
			switch(e.expr){
				case EVars(vars):
					for (v in vars) {
						if (!privateCamelCaseRE.match(v.name)) logPos('Invalid casing of variable ${v.name}', e.pos, SeverityLevel.WARNING);
					}
				default:
			}
		});
	}

	function _warnPrivateKeyword(name:String, pos:Position) {
		logPos('No need of private keyword \"${name}\" (fields are by default private in classes)', pos, SeverityLevel.INFO);
	}

	function _warnPublicKeyword(name:String, pos:Position) {
		logPos('No need of public keyword \"${name}\" (fields are by default public in interfaces)', pos, SeverityLevel.INFO);
	}

	function _warnPrivate(name:String, pos:Position) {
		logPos('Invalid private signature \"${name}\" (name should be camelCase starting with underscore)', pos, SeverityLevel.ERROR);
	}

	function _warnPublic(name:String, pos:Position) {
		logPos('Invalid public signature \"${name}\" (name should be camelCase)', pos, SeverityLevel.ERROR);
	}

	function _warnVarinit(name:String, pos:Position) {
		logPos('Invalid variable initialisation \"${name}\" (move initialisation to constructor or function)', pos, SeverityLevel.ERROR);
	}

	function _warnInline(name:String, pos:Position) {
		logPos('Inline constant variables should be uppercase \"${name}\"', pos, SeverityLevel.ERROR);
	}

	function _warnVoid(name:String, pos:Position) {
		logPos('No need to return Void, Default function return value type is Void \"${name}\"', pos, SeverityLevel.INFO);
	}

	function _warnNoReturnType(name:String, pos:Position) {
		logPos('Return type not specified when returning a value for function \"${name}\"', pos, SeverityLevel.INFO);
	}
}