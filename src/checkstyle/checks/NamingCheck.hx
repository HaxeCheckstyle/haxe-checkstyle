package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("Naming")
@desc("Various checks on naming conventions")
class NamingCheck extends Check {

	public var severity:String = "ERROR";
	public var privateUnderscorePrefix:Bool = true;

	var privateCamelCaseRE = ~/^_?[a-z0-9_]*$/i;
	var publicCamelCaseRE = ~/^[a-z0-9_]*$/i;
	var bigCamelCaseRE = ~/^_?[A-Z]\w*$/;
	var capsRE = ~/^_?[A-Z][A-Z0-9_]*$/;

	override function actualRun() {
		if (!privateUnderscorePrefix) privateCamelCaseRE = ~/^[a-z0-9_]*$/i;
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
		else isPrivate = true;

		_genericCheck(isInline, isPrivate, isPublic, isStatic, f);
	}

	function _genericCheck(isInline:Bool, isPrivate:Bool, isPublic:Bool, isStatic:Bool, f:Field) {
		//trace(Std.string(f.kind));
		if (isPrivate || isPublic) {
			var underscore:Int = f.name.lastIndexOf("_");
			var set:Int = f.name.indexOf("set_");
			var get:Int = f.name.indexOf("get_");
			if (isPrivate && (!privateCamelCaseRE.match(f.name) || (privateUnderscorePrefix && underscore == -1) || (underscore > 0 && set == -1 && get == -1) || underscore > 3 || (underscore > 0 && underscore < 3))) {
				_warnPrivate(f.name, f.pos);
				return;
			}
			else if (isPublic && (!publicCamelCaseRE.match(f.name) || (underscore > -1 && set == -1 && get == -1) || underscore > 3 || (underscore > -1 && underscore < 3))) {
				_warnPublic(f.name, f.pos);
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
						if (!privateCamelCaseRE.match(v.name)) logPos('Invalid casing of variable ${v.name}', e.pos, Reflect.field(SeverityLevel, severity));
					}
				default:
			}
		});
	}

	function _warnPrivate(name:String, pos:Position) {
		if (privateUnderscorePrefix) logPos('Invalid private signature \"${name}\" (name should be camelCase starting with underscore)', pos, Reflect.field(SeverityLevel, severity));
		else logPos('Invalid private signature \"${name}\" (name should be camelCase)', pos, Reflect.field(SeverityLevel, severity));
	}

	function _warnPublic(name:String, pos:Position) {
		logPos('Invalid public signature \"${name}\" (name should be camelCase)', pos, Reflect.field(SeverityLevel, severity));
	}

	function _warnInline(name:String, pos:Position) {
		logPos('Inline constant variables should be uppercase \"${name}\"', pos, Reflect.field(SeverityLevel, severity));
	}
}