package checkstyle.checks.coding;

/**
	Checks that a local variable or a parameter does not shadow a field that is defined in the same class.
**/
@name("HiddenField")
@desc("Checks that a local variable or a parameter does not shadow a field that is defined in the same class.")
class HiddenFieldCheck extends Check {
	static inline var MAX_FIELD_LEVEL:Int = 3;

	/**
		allow constructor parameters to shadow field names
	**/
	public var ignoreConstructorParameter:Bool;

	/**
		allow setters to shadow field names
	**/
	public var ignoreSetter:Bool;

	/**
		ignore function names matching "ignoreFormat" regex
	**/
	public var ignoreFormat:String;

	public function new() {
		super(TOKEN);
		ignoreConstructorParameter = true;
		ignoreSetter = true;
		ignoreFormat = "^(main|run)$";
		categories = [Category.COMPLEXITY, Category.CLARITY, Category.BUG_RISK];
		points = 5;
	}

	override function actualRun() {
		var ignoreFormatRE:EReg = new EReg(ignoreFormat, "");
		var root:TokenTree = checker.getTokenTree();
		checkClasses(root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdClass):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		}), ignoreFormatRE);
	}

	function checkClasses(classes:Array<TokenTree>, ignoreFormatRE:EReg) {
		for (clazz in classes) {
			if (isPosSuppressed(clazz.pos)) continue;
			var memberNames:Array<String> = collectMemberNames(clazz);
			var methods:Array<TokenTree> = clazz.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				return switch (token.tok) {
					case Kwd(KwdFunction):
						FoundSkipSubtree;
					default:
						GoDeeper;
				}
			});
			for (method in methods) {
				if (isPosSuppressed(method.pos)) continue;
				checkMethod(method, memberNames, ignoreFormatRE);
			}
		}
	}

	function checkMethod(method:TokenTree, memberNames:Array<String>, ignoreFormatRE:EReg) {
		if (!method.hasChildren()) throw "function has invalid structure!";

		// handle constructor and setters
		var methodName:TokenTree = method.children[0];
		if (methodName.matches(Kwd(KwdNew)) && ignoreConstructorParameter) return;
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
					if ('set_${member.toLowerCase()}' == name.toLowerCase() || 'set${member.toLowerCase()}' == name.toLowerCase()) {
						return true;
					}
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
		var paramDef:Array<TokenTree> = method.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (depth > 2) return SkipSubtree;
			return switch (token.tok) {
				case POpen:
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});

		if ((paramDef == null) || (paramDef.length != 1)) {
			throw "function parameters have invalid structure!";
		}
		var paramList:Array<TokenTree> = paramDef[0].children;
		for (param in paramList) checkName(param, memberNames, "Parameter definition");
	}

	function checkVars(method:TokenTree, memberNames:Array<String>) {
		var vars:Array<TokenTree> = method.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdVar):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
		for (v in vars) {
			if (!v.hasChildren()) throw "var has invalid structure!";
			checkName(v.children[0], memberNames, "Variable definition");
		}
	}

	function checkForLoops(method:TokenTree, memberNames:Array<String>) {
		var fors:Array<TokenTree> = method.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdFor):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});
		for (f in fors) {
			var popens:Array<TokenTree> = f.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				if (depth > 2) return SkipSubtree;
				return switch (token.tok) {
					case POpen:
						FoundSkipSubtree;
					default:
						GoDeeper;
				}
			});
			if (popens.length <= 0) continue;
			var pOpen:TokenTree = popens[0];
			if (!pOpen.hasChildren()) continue;
			checkName(pOpen.children[0], memberNames, "For loop definition");
		}
	}

	function checkName(token:TokenTree, memberNames:Array<String>, logText:String) {
		switch (token.tok) {
			case Const(CIdent(name)):
				if (memberNames.contains(name)) {
					logPos('$logText of "$name" masks member of same name', token.pos);
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
		var varFields:Array<TokenTree> = clazz.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (depth > MAX_FIELD_LEVEL) return SkipSubtree;
			return switch (token.tok) {
				case Kwd(KwdVar):
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});
		for (member in varFields) {
			if (!member.hasChildren()) continue;
			switch (member.children[0].tok) {
				case Const(CIdent(name)):
					memberNames.push(name);
				default:
			}
		}
		return memberNames;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "ignoreConstructorParameter",
				values: [true, false]
			}, {
				propertyName: "ignoreSetter",
				values: [true, false]
			}]
		}];
	}
}