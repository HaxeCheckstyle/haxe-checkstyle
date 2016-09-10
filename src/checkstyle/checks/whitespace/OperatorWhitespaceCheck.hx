package checkstyle.checks.whitespace;

import checkstyle.token.TokenTree;
import checkstyle.utils.TokenTreeCheckUtils;
import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespacePolicy;
import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespaceUnaryPolicy;
import haxeparser.Data;

@name("OperatorWhitespace")
@desc("Checks that whitespace is present or absent around a operators.")
class OperatorWhitespaceCheck extends WhitespaceCheckBase {

	// =, +=, -=, *=, /=, <<=, >>=, >>>=, &=, |=, ^=
	public var assignOpPolicy:WhitespacePolicy;
	// ++, --, !
	public var unaryOpPolicy:WhitespaceUnaryPolicy;
	// ?:
	public var ternaryOpPolicy:WhitespacePolicy;
	// +, -, *, /, %
	public var arithmeticOpPolicy:WhitespacePolicy;
	// ==, !=, <, <=, >, >=
	public var compareOpPolicy:WhitespacePolicy;
	// ~, &, |, ^, <<, >>, >>>
	public var bitwiseOpPolicy:WhitespacePolicy;
	// &&, ||
	public var boolOpPolicy:WhitespacePolicy;
	// ...
	public var intervalOpPolicy:WhitespacePolicy;
	// =>
	public var arrowPolicy:WhitespacePolicy;
	// ->
	public var functionArgPolicy:WhitespacePolicy;

	public function new() {
		super();
		assignOpPolicy = AROUND;
		unaryOpPolicy = NONE;
		ternaryOpPolicy = AROUND;
		arithmeticOpPolicy = AROUND;
		compareOpPolicy = AROUND;
		bitwiseOpPolicy = AROUND;
		boolOpPolicy = AROUND;
		intervalOpPolicy = NONE;
		arrowPolicy = AROUND;
		functionArgPolicy = AROUND;
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();

		checkAssignOps(root);
		checkUnaryOps(root);
		checkTernaryOps(root);
		checkArithmeticOps(root);
		checkCompareOps(root);
		checkBitwiseOps(root);
		checkBoolOps(root);
		checkIntervalOps(root);
		checkArrowOps(root);
		checkFunctionArg(root);
	}

	function checkAssignOps(root:TokenTree) {
		checkTokens(root, [
				Binop(OpAssign),
				Binop(OpAssignOp(OpAdd)),
				Binop(OpAssignOp(OpSub)),
				Binop(OpAssignOp(OpMult)),
				Binop(OpAssignOp(OpDiv)),
				Binop(OpAssignOp(OpMod)),
				Binop(OpAssignOp(OpShl)),
				Binop(OpAssignOp(OpShr)),
				Binop(OpAssignOp(OpUShr)),
				Binop(OpAssignOp(OpOr)),
				Binop(OpAssignOp(OpAnd)),
				Binop(OpAssignOp(OpXor))
			], assignOpPolicy);
	}

	function checkUnaryOps(root:TokenTree) {
		if ((unaryOpPolicy == null) || (unaryOpPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([
				Unop(OpNot),
				Unop(OpIncrement),
				Unop(OpDecrement)
			], ALL);

		for (token in tokens) {
			if (isPosSuppressed(token.pos)) continue;
			checkUnaryWhitespace(token, unaryOpPolicy);
		}
	}

	function checkTernaryOps(root:TokenTree) {
		if ((ternaryOpPolicy == null) || (ternaryOpPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([Question], ALL);

		for (token in tokens) {
			if (isPosSuppressed(token.pos)) continue;
			if (!TokenTreeCheckUtils.isTernary(token)) continue;
			// ?
			checkWhitespace(token, ternaryOpPolicy);
			// :
			checkWhitespace(token.getLastChild(), ternaryOpPolicy);
		}
	}

	function checkArithmeticOps(root:TokenTree) {
		checkTokens(root, [
				Binop(OpAdd),
				Binop(OpSub),
				Binop(OpMult),
				Binop(OpDiv),
				Binop(OpMod)
			], arithmeticOpPolicy);
	}

	function checkCompareOps(root:TokenTree) {
		checkTokens(root, [
				Binop(OpGt),
				Binop(OpLt),
				Binop(OpGte),
				Binop(OpLte),
				Binop(OpEq),
				Binop(OpNotEq)
			], compareOpPolicy);
	}

	function checkBitwiseOps(root:TokenTree) {
		checkTokens(root, [
				Binop(OpAnd),
				Binop(OpOr),
				Binop(OpXor),
				Binop(OpShl),
				Binop(OpShr),
				Binop(OpUShr)
			], bitwiseOpPolicy);
	}

	function checkBoolOps(root:TokenTree) {
		checkTokens(root, [
				Binop(OpBoolAnd),
				Binop(OpBoolOr)
			], boolOpPolicy);
	}

	function checkIntervalOps(root:TokenTree) {
		if ((intervalOpPolicy == null) || (intervalOpPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (token.tok == null) return GO_DEEPER;
			return switch (token.tok) {
				case Binop(OpInterval): FOUND_SKIP_SUBTREE;
				case IntInterval(_): FOUND_SKIP_SUBTREE;
				default: GO_DEEPER;
			}
		});
		checkTokenList(tokens, intervalOpPolicy);
	}

	function checkArrowOps(root:TokenTree) {
		if ((arrowPolicy == null) || (arrowPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([Binop(OpArrow)], ALL);
		checkTokenList(tokens, arrowPolicy);
	}

	function checkFunctionArg(root:TokenTree) {
		if ((functionArgPolicy == null) || (functionArgPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([Arrow], ALL);
		checkTokenList(tokens, functionArgPolicy);
	}

	override function violation(tok:TokenTree, policy:String) {
		logPos('OperatorWhitespace policy "$policy" violated by "${TokenDefPrinter.print(tok.tok)}"', tok.pos);
	}
}