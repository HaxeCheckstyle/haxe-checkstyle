package checkstyle.checks.coding;

/**
	Checks for over-complicated boolean return statements.
**/
@name("SimplifyBooleanReturn")
@desc("Checks for over-complicated boolean return statements.")
class SimplifyBooleanReturnCheck extends Check {
	public function new() {
		super(TOKEN);
		categories = [Category.COMPLEXITY];
		points = 2;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdIf):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (token in acceptableTokens) {
			var elseLiteral = token.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
				return switch (token.tok) {
					case Kwd(KwdElse):
						FoundSkipSubtree;
					default:
						GoDeeper;
				}
			})[0];
			if (elseLiteral == null) continue;

			var elseStatement = elseLiteral.getFirstChild();
			var thenStatement = token.children[1];

			if (canReturnOnlyBooleanLiteral(thenStatement) && canReturnOnlyBooleanLiteral(elseStatement)) {
				logPos("Conditional logic can be removed", token.pos);
			}
		}
	}

	function canReturnOnlyBooleanLiteral(tkn:TokenTree):Bool {
		if (isBooleanLiteralReturnStatement(tkn)) return true;
		return isBooleanLiteralReturnStatement(tkn.getFirstChild());
	}

	function isBooleanLiteralReturnStatement(tkn:TokenTree):Bool {
		var booleanReturnStatement = false;
		if (tkn != null && tkn.matches(Kwd(KwdReturn))) {
			var expr = tkn.getFirstChild();
			booleanReturnStatement = isBooleanLiteralType(expr);
		}
		return booleanReturnStatement;
	}

	function isBooleanLiteralType(tkn:TokenTree):Bool {
		return tkn.matches(Kwd(KwdTrue)) || tkn.matches(Kwd(KwdFalse));
	}
}