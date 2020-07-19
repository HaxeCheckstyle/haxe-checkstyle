package checkstyle.checks.coding;

import checkstyle.utils.StringUtils;

/**
	Checks for unused local variables.
**/
@name("UnusedLocalVar")
@desc("Checks for unused local variables.")
class UnusedLocalVarCheck extends Check {
	public function new() {
		super(TOKEN);
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var functions:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdFunction):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (f in functions) {
			if (isPosSuppressed(f.pos)) continue;
			var skipFirstFunction:Bool = true;
			var localVars:Array<TokenTree> = f.filterCallback(function(tok:TokenTree, depth:Int):FilterResult {
				return switch (tok.tok) {
					case Kwd(KwdVar): FoundSkipSubtree;
					case Kwd(KwdFunction):
						if (skipFirstFunction) {
							skipFirstFunction = false;
							GoDeeper;
						}
						else SkipSubtree;
					default: GoDeeper;
				}
			});
			checkLocalVars(f, localVars);
		}
	}

	function checkLocalVars(f:TokenTree, localVars:Array<TokenTree>) {
		for (localVar in localVars) {
			for (child in localVar.children) {
				switch (child.tok) {
					case Const(CIdent(name)):
						checkLocalVar(f, child, name);
					default:
				}
			}
		}
	}

	function checkLocalVar(f:TokenTree, v:TokenTree, name:String) {
		var ignoreFunctionSignature:Bool = true;
		var nameList:Array<TokenTree> = f.filterCallback(function(tok:TokenTree, depth:Int):FilterResult {
			if (ignoreFunctionSignature) {
				switch (tok.tok) {
					case Kwd(KwdPublic), Kwd(KwdPrivate):
						return SkipSubtree;
					case At:
						return SkipSubtree;
					case Comment(_), CommentLine(_):
						return SkipSubtree;
					case POpen:
						ignoreFunctionSignature = false;
						return SkipSubtree;
					default:
						return GoDeeper;
				}
			}
			return switch (tok.tok) {
				case Dollar(n):
					if (n == name) FoundGoDeeper; else GoDeeper;
				case Const(CIdent(n)):
					if (n == name) FoundGoDeeper; else GoDeeper;
				case Const(CString(s)):
					checkStringInterpolation(tok, name, s);
				default: GoDeeper;
			}
		});
		if (nameList.length > 1) return;

		logPos('Unused local variable $name', v.pos);
	}

	function checkStringInterpolation(tok:TokenTree, name:String, s:String):FilterResult {
		if (!StringUtils.isStringInterpolation(s, checker.file.content, tok.pos)) {
			return GoDeeper;
		}

		// $name
		var format:String = "\\$" + name + "([^_0-9a-zA-Z]|$)";
		var r:EReg = new EReg(format, "");
		if (r.match(s)) {
			return FoundGoDeeper;
		}

		// '${name.doSomething()} or ${doSomething(name)} or ${name}
		format = "\\$\\{(|.*[^_0-9a-zA-Z])" + name + "([^_0-9a-zA-Z].*|)\\}";
		r = new EReg(format, "");
		if (r.match(s)) {
			return FoundGoDeeper;
		}
		return GoDeeper;
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: [SeverityLevel.INFO]
			}]
		}];
	}
}