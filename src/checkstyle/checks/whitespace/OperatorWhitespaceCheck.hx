package checkstyle.checks.whitespace;

import checkstyle.Checker.LinePos;
import checkstyle.token.TokenTree;
import checkstyle.utils.TokenTreeCheckUtils;
import checkstyle.checks.whitespace.WhitespaceCheck.WhitespacePolicy;
import checkstyle.checks.whitespace.WhitespaceCheck.WhitespaceUnaryPolicy;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.ArrayUtils;

@name("OperatorWhitespace")
@desc("Checks that whitespace is present or absent around a operators.")
class OperatorWhitespaceCheck extends Check {

	// =, +=, -=, *=, /=, <<=, >>=, >>>=, &=, |=, ^=
	public var assignOpPolicy:WhitespacePolicy;
	// ++, --, !
	public var unaryOpPolicy:WhitespaceUnaryPolicy;
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

	public function new() {
		super(TOKEN);
		assignOpPolicy = AROUND;
		unaryOpPolicy = NONE;
		arithmeticOpPolicy = AROUND;
		compareOpPolicy = AROUND;
		bitwiseOpPolicy = AROUND;
		boolOpPolicy = AROUND;
		intervalOpPolicy = NONE;

		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();

		checkAssignOps(root);
		checkUnaryOps(root);
		checkArithmeticOps(root);
		checkCompareOps(root);
		checkBitwiseOps(root);
		checkBoolOps(root);
		checkIntervalOps(root);
	}

	function checkAssignOps(root:TokenTree) {
		if ((assignOpPolicy == null) || (assignOpPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([
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
			], ALL);

		checkTokenList(tokens, assignOpPolicy);
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

	function checkArithmeticOps(root:TokenTree) {
		if ((arithmeticOpPolicy == null) || (arithmeticOpPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([
				Binop(OpAdd),
				Binop(OpSub),
				Binop(OpMult),
				Binop(OpDiv),
				Binop(OpMod)
			], ALL);
		checkTokenList(tokens, arithmeticOpPolicy);
	}

	function checkCompareOps(root:TokenTree) {
		if ((compareOpPolicy == null) || (compareOpPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([
				Binop(OpGt),
				Binop(OpLt),
				Binop(OpGte),
				Binop(OpLte),
				Binop(OpEq),
				Binop(OpNotEq)
			], ALL);
		checkTokenList(tokens, compareOpPolicy);
	}

	function checkBitwiseOps(root:TokenTree) {
		if ((bitwiseOpPolicy == null) || (bitwiseOpPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([
				Binop(OpAnd),
				Binop(OpOr),
				Binop(OpXor),
				Binop(OpShl),
				Binop(OpShr),
				Binop(OpUShr)
			], ALL);
		checkTokenList(tokens, bitwiseOpPolicy);
	}

	function checkBoolOps(root:TokenTree) {
		if ((boolOpPolicy == null) || (boolOpPolicy == IGNORE)) return;
		var tokens:Array<TokenTree> = root.filter([
				Binop(OpBoolAnd),
				Binop(OpBoolOr)
			], ALL);
		checkTokenList(tokens, boolOpPolicy);
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

	function checkTokenList(tokens:Array<TokenTree>, policy:WhitespacePolicy) {
		for (token in tokens) {
			if (isPosSuppressed(token.pos)) continue;
			if (TokenTreeCheckUtils.isImportMult(token)) continue;
			if (TokenTreeCheckUtils.isTypeParameter(token)) continue;
			if (TokenTreeCheckUtils.filterOpSub(token)) continue;
			checkWhitespace(token, policy);
		}
	}

	function checkWhitespace(tok:TokenTree, policy:WhitespacePolicy) {
		var linePos:LinePos = checker.getLinePos(tok.pos.min);
		var tokLen:Int = TokenDefPrinter.print(tok.tok).length;
		if (tok.tok.match(IntInterval(_))) {
			linePos = checker.getLinePos(tok.pos.max - 3);
			tokLen = 3;
		}
		var line:String = checker.lines[linePos.line];
		var before:String = line.substr(0, linePos.ofs);
		var after:String = line.substr(linePos.ofs + tokLen);

		var whitespaceBefore:Bool = ~/^(.*\s|)$/.match(before);
		var whitespaceAfter:Bool = ~/^(\s.*|)$/.match(after);

		switch (policy) {
			case BEFORE:
				if (whitespaceBefore && !whitespaceAfter) return;
			case AFTER:
				if (!whitespaceBefore && whitespaceAfter) return;
			case NONE:
				if (!whitespaceBefore && !whitespaceAfter) return;
			case AROUND:
				if (whitespaceBefore && whitespaceAfter) return;
			case IGNORE:
				return;
			default:
				return;
		}
		logPos('OperatorWhitespace policy "$policy" violated by "${TokenDefPrinter.print(tok.tok)}"', tok.pos);
	}

	function checkUnaryWhitespace(tok:TokenTree, policy:WhitespaceUnaryPolicy) {
		var linePos:LinePos = checker.getLinePos(tok.pos.min);
		var tokLen:Int = TokenDefPrinter.print(tok.tok).length;
		var line:String = checker.lines[linePos.line];
		var before:String = line.substr(0, linePos.ofs);
		var after:String = line.substr(linePos.ofs + tokLen);

		var whitespaceBefore:Bool = ~/^(.*\s|)$/.match(before);
		var whitespaceAfter:Bool = ~/^(\s.*|)$/.match(after);

		var leftSide:Bool = TokenTreeCheckUtils.isUnaryLeftSided(tok);

		switch (policy) {
			case INNER:
				if (leftSide && whitespaceAfter) return;
				if (!leftSide && whitespaceBefore) return;
			case NONE:
				if (leftSide && !whitespaceAfter) return;
				if (!leftSide && !whitespaceBefore) return;
			case IGNORE:
				return;
			default:
				return;
		}
		logPos('OperatorWhitespace policy "$policy" violated by "${TokenDefPrinter.print(tok.tok)}"', tok.pos);
	}
}