package checkstyle.checks.whitespace;

import checkstyle.utils.TokenTreeCheckUtils;
import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespacePolicy;
import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespaceUnaryPolicy;

/**
	Checks that whitespace is present or absent around a operators.
 **/
@name("OperatorWhitespace")
@desc("Checks that whitespace is present or absent around a operators.")
class OperatorWhitespaceCheck extends WhitespaceCheckBase {

	/**
		policy for "=", "+=", "-=", "*=", "/=", "<<=", ">>=", ">>>=", "&=", "|=", "^="
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
	public var assignOpPolicy:WhitespacePolicy;

	/**
		policy for "++", "--", "!", "~"
		- inner = enforce whitespace between unary operator and operand
		- none = enforce no whitespace between unary operator and operand
		- ignore = skip checks
	 **/
	public var unaryOpPolicy:WhitespaceUnaryPolicy;

	/**
		policy for "?:"
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
	public var ternaryOpPolicy:WhitespacePolicy;

	/**
		policy for "+", "-", "*", "/", "%"
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
	public var arithmeticOpPolicy:WhitespacePolicy;

	/**
		policy for "==", "!=", "<", "<=", ">", ">="
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
	public var compareOpPolicy:WhitespacePolicy;

	/**
		policy for "&", "|", "^", "<<", ">>", ">>>"
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
	public var bitwiseOpPolicy:WhitespacePolicy;

	/**
		policy for "&&", "||"
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
	public var boolOpPolicy:WhitespacePolicy;

	/**
		policy for "..."
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
	public var intervalOpPolicy:WhitespacePolicy;

	/**
		policy for "=>"
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
	public var arrowPolicy:WhitespacePolicy;

	/**
		policy for "->"
		- around = enforce whitespace before and after operator
		- before = enforce whitespace before and no whitespace after operator
		- after = enforce no whitespace before and whitespace after operator
		- none = enforce no whitespace before and after operator
		- ignore = skip checks
	 **/
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
				Unop(OpNegBits),
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
		logPos('OperatorWhitespace policy "$policy" violated by "$tok"', tok.pos);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "assignOpPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			},
			{
				propertyName: "ternaryOpPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			},
			{
				propertyName: "arithmeticOpPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			},
			{
				propertyName: "unaryOpPolicy",
				values: [INNER, NONE, IGNORE]
			},
			{
				propertyName: "compareOpPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			},
			{
				propertyName: "bitwiseOpPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			},
			{
				propertyName: "boolOpPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			},
			{
				propertyName: "intervalOpPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			},
			{
				propertyName: "arrowPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			},
			{
				propertyName: "functionArgPolicy",
				values: [BEFORE, AFTER, AROUND, NONE, IGNORE]
			}]
		}];
	}
}