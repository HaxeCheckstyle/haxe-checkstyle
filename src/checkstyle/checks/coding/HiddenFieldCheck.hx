package checkstyle.checks.coding;

import checkstyle.token.TokenTree;
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
			var methods:Array<TokenTree> = clazz.filter([Kwd(KwdFunction)], FIRST);
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
		checkForLoops(method, memberNames);
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
			checkName(param, memberNames, "Parameter definition");
		}
	}

	function checkVars(method:TokenTree, memberNames:Array<String>) {
		var vars:Array<TokenTree> = method.filter([Kwd(KwdVar)], ALL);
		for (v in vars) {
			if (!v.hasChilds()) throw "var has invalid structure!";
			checkName(v.childs[0], memberNames, "Variable definition");
		}
	}

	function checkForLoops(method:TokenTree, memberNames:Array<String>) {
		var fors:Array<TokenTree> = method.filter([Kwd(KwdFor)], ALL);
		for (f in fors) {
			var popens:Array<TokenTree> = f.filter([POpen], FIRST, 2);
			if (popens.length <= 0) continue;
			var pOpen:TokenTree = popens[0];
			if (!pOpen.hasChilds()) continue;
			checkName(pOpen.childs[0], memberNames, "For loop definition");
		}
	}

	function checkName(token:TokenTree, memberNames:Array<String>, logText:String) {
		switch (token.tok) {
			case Const(CIdent(name)):
				if (memberNames.indexOf(name) >= 0) {
					logPos('$logText of "$name" masks member of same name', token.pos, severity);
				}
			default:
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
			if (!member.hasChilds()) continue;
			switch (member.childs[0].tok) {
				case Const(CIdent(name)):
					memberNames.push(name);
				default:
			}
		}
		return memberNames;
	}
}