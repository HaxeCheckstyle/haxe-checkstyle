package checkstyle.checks.coding;

import checkstyle.token.TokenTree;

@name("SimplifyBooleanReturn")
@desc("Checks for over-complicated boolean return statements")
class SimplifyBooleanReturnCheck extends Check {

	public function new() {
		super(TOKEN);
		categories = ["Complexity"];
		points = 2;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filter([Kwd(KwdIf)], ALL);

		for (token in acceptableTokens) {
			var elseLiteral = token.filter([Kwd(KwdElse)], FIRST)[0];
			if (elseLiteral == null) continue;

			var elseStatement = elseLiteral.getFirstChild();
			var thenStatement = token.childs[1];

			if (canReturnOnlyBooleanLiteral(thenStatement) && canReturnOnlyBooleanLiteral(elseStatement)) {
				logPos('Conditional logic can be removed', token.pos);
			}
		}
	}

	function canReturnOnlyBooleanLiteral(tkn:TokenTree):Bool {
		if (isBooleanLiteralReturnStatement(tkn)) return true;
		return isBooleanLiteralReturnStatement(tkn.getFirstChild());
	}

	function isBooleanLiteralReturnStatement(tkn:TokenTree):Bool {
		var booleanReturnStatement = false;
		if (tkn != null && tkn.is(Kwd(KwdReturn))) {
			var expr = tkn.getFirstChild();
			booleanReturnStatement = isBooleanLiteralType(expr);
		}
		return booleanReturnStatement;
	}

	function isBooleanLiteralType(tkn:TokenTree):Bool {
		return tkn.is(Kwd(KwdTrue)) || tkn.is(Kwd(KwdFalse));
	}
}