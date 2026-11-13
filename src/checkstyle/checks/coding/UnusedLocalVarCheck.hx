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
				case Arrow if (isOutermostArrowFunction(token)):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (f in functions) {
			if (isPosSuppressed(f.pos)) continue;
			var skipFirstFunction:Bool = f.matches(Kwd(KwdFunction));
			var localVars:Array<TokenTree> = f.filterCallback(function(tok:TokenTree, depth:Int):FilterResult {
				return switch (tok.tok) {
					case Kwd(KwdVar), Kwd(KwdFinal): FoundGoDeeper;
					case DblDot if (isVarTypeHint(tok)): SkipSubtree;
					case Kwd(KwdFunction):
						if (skipFirstFunction) {
							skipFirstFunction = false;
							GoDeeper;
						}
						else SkipSubtree;
					case BrOpen if (TokenTreeCheckUtils.getBrOpenType(tok) == AnonType): SkipSubtree;
					default: GoDeeper;
				}
			});
			checkLocalVars(f, localVars);
		}
	}

	function isVarTypeHint(token:TokenTree):Bool {
		var name:Null<TokenTree> = token.parent;
		if (name == null || name.parent == null) {
			return false;
		}

		return switch (name.parent.tok) {
			case Kwd(KwdVar), Kwd(KwdFinal): true;
			default: false;
		}
	}

	function isOutermostArrowFunction(token:TokenTree):Bool {
		if (TokenTreeCheckUtils.determineArrowType(token) != ArrowFunction) {
			return false;
		}

		var parent:Null<TokenTree> = token.parent;
		while (parent != null) {
			switch (parent.tok) {
				case Kwd(KwdFunction):
					return false;
				case Arrow if (TokenTreeCheckUtils.determineArrowType(parent) == ArrowFunction):
					return false;
				default:
			}

			parent = parent.parent;
		}

		return true;
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
		var ignoreFunctionSignature:Bool = f.matches(Kwd(KwdFunction));
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