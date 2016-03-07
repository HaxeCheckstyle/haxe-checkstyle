package checkstyle.checks.block;

import checkstyle.Checker.LinePos;
import checkstyle.LintMessage.SeverityLevel;
import checkstyle.token.TokenTree;
import haxeparser.Data;
import haxe.macro.Expr;

@name("NeedBraces")
@desc("Checks for braces on function, if, for and while statements")
class NeedBracesCheck extends Check {

	public var tokens:Array<NeedBracesCheckToken>;
	public var allowSingleLineStatement:Bool;

	public function new() {
		super();
		tokens = [FOR, IF, ELSE_IF, WHILE, DO_WHILE];
		allowSingleLineStatement = true;
	}

	function hasToken(token:NeedBracesCheckToken):Bool {
		return (tokens.length == 0 || tokens.indexOf(token) > -1);
	}

	override function actualRun() {
		var tokenList:Array<TokenDef> = [];

		if (hasToken(FUNCTION)) tokenList.push(Kwd(KwdFunction));
		if (hasToken(FOR)) tokenList.push(Kwd(KwdFor));
		if (hasToken(IF)) {
			tokenList.push(Kwd(KwdIf));
			tokenList.push(Kwd(KwdElse));
		}
		if (hasToken(WHILE)) tokenList.push(Kwd(KwdWhile));
		if (hasToken(DO_WHILE)) tokenList.push(Kwd(KwdDo));
		if (hasToken(CATCH)) tokenList.push(Kwd(KwdCatch));

		if (tokenList.length <= 0) return;

		var root:TokenTree = checker.getTokenTree();
		var allTokens:Array<TokenTree> = root.filter(tokenList, ALL);

		for (tok in allTokens) {
			if (isPosSuppressed(tok.pos)) continue;
			switch (tok.tok) {
				case Kwd(KwdIf):
					checkIfChild(tok);
				case Kwd(KwdFunction):
					checkFunctionChild(tok);
				case Kwd(KwdDo):
					checkDoWhileChild(tok);
				case Kwd(KwdWhile):
					checkWhileChild(tok);
				default:
					checkLastChild(tok);
			}
		}
	}

	function checkIfChild(token:TokenTree) {
		if (token == null || !token.hasChilds()) return;

		var lastChild:TokenTree = token.getLastChild();
		if (Type.enumEq(lastChild.tok, Kwd(KwdElse))) {
			lastChild = lastChild.previousSibling;
		}
		switch (lastChild.tok) {
			case POpen, BrOpen:
				return;
			default:
				checkNoBraces(token, lastChild);
		}
	}

	function checkFunctionChild(token:TokenTree) {
		if (token == null || !token.hasChilds()) return;

		var lastChild:TokenTree = token.getLastChild();
		switch (lastChild.tok) {
			case Const(CIdent(_)), Kwd(KwdNew):
				if (!lastChild.hasChilds()) return;
				lastChild = lastChild.getLastChild();
			default:
		}
		switch (lastChild.tok) {
			case BrOpen:
				return;
			case Semicolon:
				return;
			default:
				checkNoBraces(token, lastChild);
		}
	}

	function checkDoWhileChild(token:TokenTree) {
		if (token == null || !token.hasChilds()) return;

		var lastChild:TokenTree = token.getLastChild();
		var expr:TokenTree = lastChild.previousSibling;
		switch (expr.tok) {
			case BrOpen:
				return;
			default:
				checkNoBraces(token, lastChild);
		}
	}

	function checkWhileChild(token:TokenTree) {
		if (token == null || !token.hasChilds() || Type.enumEq(token.parent.tok, Kwd(KwdDo))) return;
		var lastChild:TokenTree = token.getLastChild();
		switch (lastChild.tok) {
			case BrOpen:
				return;
			default:
				checkNoBraces(token, lastChild);
		}
	}

	function checkLastChild(token:TokenTree) {
		if (token == null || !token.hasChilds()) return;

		var lastChild:TokenTree = token.getLastChild();
		switch (lastChild.tok) {
			case BrOpen:
				return;
			default:
				checkNoBraces(token, lastChild);
		}
	}

	function checkNoBraces(parent:TokenTree, child:TokenTree) {
		var minLine:LinePos = checker.getLinePos(parent.pos.min);
		var maxLine:LinePos = checker.getLinePos(child.getPos().max);
		var singleLine:Bool = (minLine.line == maxLine.line);

		if (allowSingleLineStatement) {
			if (singleLine) return;
			if (checkIfElseSingleline(parent, child)) return;
		}
		else {
			if (singleLine) {
				logPos('Body of "${TokenDefPrinter.print(parent.tok)}" on same line', child.pos, severity);
				return;
			}
		}
		logPos('No braces used for body of "${TokenDefPrinter.print(parent.tok)}"', child.pos, severity);
	}

	function checkIfElseSingleline(parent:TokenTree, child:TokenTree):Bool {
		if (!hasToken(ELSE_IF)) return false;
		switch (parent.tok) {
			case Kwd(KwdElse):
			default:
				return false;
		}
		switch (child.tok) {
			case Kwd(KwdIf):
			default:
				return false;
		}
		var minLine:LinePos = checker.getLinePos(parent.pos.min);
		var maxLine:LinePos = checker.getLinePos(child.getFirstChild().getPos().max);
		return (minLine.line == maxLine.line);
	}
}

@:enum
abstract NeedBracesCheckToken(String) {
	var FUNCTION = "FUNCTION";
	var FOR = "FOR";
	var IF = "IF";
	var ELSE_IF = "ELSE_IF";
	var WHILE = "WHILE";
	var DO_WHILE = "DO_WHILE";
	var CATCH = "CATCH";
}