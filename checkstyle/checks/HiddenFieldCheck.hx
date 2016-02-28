package checkstyle.checks;

import haxe.macro.Expr;
import haxeparser.Data.TokenDef;
import checkstyle.LintMessage.SeverityLevel;

@name("HiddenField")
@desc("Checks that a local variable or parameter does not shadow a field")
class HiddenFieldCheck extends Check {
	static inline var MAX_FIELD_LEVEL:Int = 3;

	public var ignoreConstructorParameter:Bool;
	public var ignoreSetter:Bool;
	public var ignoreFormat:String;

	var ignoreFormatRE:EReg;

	public function new() {
		super();
		ignoreConstructorParameter = true;
		ignoreSetter = true;
		ignoreFormat = "^(main|run)$";
		ignoreFormatRE = null;
	}

	override function actualRun() {
		if (ignoreFormat != null) ignoreFormatRE = new EReg (ignoreFormat, "");
		var root:TokenTree = checker.getTokenTree();
		checkClasses(root.filter([Kwd(KwdClass)], ALL));
	}

	function checkClasses(classes:Array<TokenTree>) {
		for (clazz in classes) {
			if (isPosSuppressed(clazz.pos)) continue;
			var memberNames:Array<String> = collectMemberNames(clazz);
			var methods:Array<TokenTree> = clazz.filter([Kwd(KwdFunction)], FIRST, MAX_FIELD_LEVEL);
			for (method in methods) {
				if (isPosSuppressed(method.pos)) continue;
				checkMethod(method, memberNames);
			}
		}
	}

	function checkMethod(method:TokenTree, memberNames:Array<String>) {
		if (!method.hasChilds()) throw "function has invalid structure!";

		// handle constructor and setters
		var methodName:TokenTree = method.childs[0];
		if (methodName.is(Kwd(KwdNew)) && ignoreConstructorParameter) return;
		if (ignoreSetter && isSetterFunction(methodName, memberNames)) return;
		switch (methodName.tok) {
			case Const(CIdent(name)):
				if (ignoreFormatRE.match(name)) return;
			case Kwd(KwdNew):
				if (ignoreFormatRE.match("new")) return;
			default:
		}

		checkParams(method, memberNames);
		checkVars(method, memberNames);
	}

	function isSetterFunction(methodName:TokenTree, memberNames:Array<String>):Bool {
		switch (methodName.tok) {
			case Const(CIdent(name)):
				for (member in memberNames) {
					// allow set_fieldName and setFieldName notation
					if ('set_${member.toLowerCase()}' == name.toLowerCase()) return true;
					if ('set${member.toLowerCase()}' == name.toLowerCase()) return true;
				}
			default:
		}
		return false;
	}

	function checkParams(method:TokenTree, memberNames:Array<String>) {
		// Kwd(KwdFunction)
		//  |- Const(CIdent(functioname))
		//      |- POpen
		//          |- parameters
		//          |- PClose
		var paramDef:Array<TokenTree> = method.filter([POpen], FIRST, 2);
		if ((paramDef == null) || (paramDef.length != 1)) {
			throw "function parameters have invalid structure!";
		}
		var paramList:Array<TokenTree> = paramDef[0].childs;
		for (param in paramList) {
			switch (param.tok) {
				case Const(CIdent(name)):
					if (memberNames.indexOf(name) >= 0) {
						logPos('Parameter definition of "$name" masks member of same name', param.pos, Reflect.field(SeverityLevel, severity));
					}
				default:
			}
		}
	}

	function checkVars(method:TokenTree, memberNames:Array<String>) {
		var vars:Array<TokenTree> = method.filter([Kwd(KwdVar)], ALL);
		for (v in vars) {
			if (!v.hasChilds()) {
				throw "var has invalid structure!";
			}
			switch (v.childs[0].tok) {
				case Const(CIdent(name)):
					if (memberNames.indexOf(name) >= 0) {
						logPos('Variable definition of "$name" masks member of same name', v.pos, Reflect.field(SeverityLevel, severity));
					}
				default:
					throw "var has invalid structure!";
			}
		}
	}

	function collectMemberNames(clazz:TokenTree):Array<String> {
		var memberNames:Array<String> = [];
		// Kwd(KwdClass)
		//  |- Const(CIdent(classname))
		//      |- BrOpen
		//          |- Kwd(KwdVar)
		//          |- Kwd(KwdVar)
		//          |- Kwd(KwdFunction)
		var varFields:Array<TokenTree> = clazz.filter([Kwd(KwdVar)], FIRST, MAX_FIELD_LEVEL);
		for (member in varFields) {
			if (!member.hasChilds()) throw "var field has invalid structure!";
			switch (member.childs[0].tok) {
				case Const(CIdent(name)):
					memberNames.push(name);
				default:
					throw "var field has invalid structure!";
			}
		}
		return memberNames;
	}
}