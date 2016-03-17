package checkstyle.checks.whitespace;

import checkstyle.Checker.LinePos;
import checkstyle.token.TokenTree;
import checkstyle.utils.TokenTreeCheckUtils;
import haxeparser.Data;
import haxe.macro.Expr;

using checkstyle.utils.ArrayUtils;

@name("Whitespace")
@desc("Checks that is present or absent around a token.")
class WhitespaceCheck extends Check {

	public var mode:WhitespaceMode;
	public var tokens:Array<WhitespaceToken>;
	public var contexts:Array<WhitespaceContext>;

	public function new() {
		super(TOKEN);
		tokens = [
			ARROW, ASSIGN, UNARY, COMPARE, BITWISE, BOOL
		];
		mode = AROUND;
		contexts = [OBJECT_DECL, FUNCTION, FIELD, SWITCH, TRY_CATCH, ARRAY_ACCESS];

		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var tokenList:Array<TokenDef> = [];

		for (token in tokens) {
			switch (token) {
				case ASSIGN:
					tokenList = tokenList.concat([
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
					]);
				case UNARY:
					tokenList = tokenList.concat([
						Unop(OpNot),
						Unop(OpIncrement),
						Unop(OpDecrement)
					]);
				case COMPARE:
					tokenList = tokenList.concat([
						Binop(OpGt),
						Binop(OpLt),
						Binop(OpGte),
						Binop(OpLte),
						Binop(OpEq),
						Binop(OpNotEq)
					]);
				case ARITHMETIC:
					tokenList = tokenList.concat([
						Binop(OpAdd),
						Binop(OpSub),
						Binop(OpMult),
						Binop(OpDiv),
						Binop(OpMod)
					]);
				case BITWISE:
					tokenList = tokenList.concat([
						Binop(OpAnd),
						Binop(OpOr),
						Binop(OpXor),
						Binop(OpShl),
						Binop(OpShr),
						Binop(OpUShr)
					]);
				case BOOL:
					tokenList.push(Binop(OpBoolAnd));
					tokenList.push(Binop(OpBoolOr));
				case ARROW:
					tokenList.push(Arrow);
				case COMMA:
					tokenList.push(Comma);
				case SEMICOLON:
					tokenList.push(Semicolon);
				case POPEN:
					tokenList.push(POpen);
				case PCLOSE:
					tokenList.push(PClose);
				case BROPEN:
					tokenList.push(BrOpen);
				case BRCLOSE:
					tokenList.push(BrClose);
				case BKOPEN:
					tokenList.push(BkOpen);
				case BKCLOSE:
					tokenList.push(BkClose);
				case DBLDOT:
					tokenList.push(DblDot);
				case DOT:
					tokenList.push(Dot);
				case INTERVAL:
					tokenList.push(Binop(OpInterval));
			}
		}

		if (tokenList.length <= 0) return;
		checkTokens(tokenList);
	}

	function checkTokens(tokenList:Array<TokenDef>) {
		var root:TokenTree = checker.getTokenTree();
		var allTokens:Array<TokenTree> = root.filter(tokenList, ALL);

		for (tok in allTokens) {
			if (isPosSuppressed(tok.pos)) continue;
			if (!checkContext(tok)) continue;

			checkWhitespace(tok);
		}
	}

	function checkWhitespace(tok:TokenTree) {
		var linePos:LinePos = checker.getLinePos(tok.pos.min);
		var line:String = checker.lines[linePos.line];
		var before:String = line.substr(0, linePos.ofs);
		var tokLen:Int = TokenDefPrinter.print(tok.tok).length;
		var after:String = line.substr(linePos.ofs + tokLen);

		var whitespaceBefore:Bool = ~/^(.*\s|)$/.match(before);
		var whitespaceAfter:Bool = ~/^(\s.*|)$/.match(after);

		switch (mode) {
			case BEFORE:
				if (whitespaceBefore && !whitespaceAfter) return;
			case AFTER:
				if (!whitespaceBefore && whitespaceAfter) return;
			case NONE:
				if (!whitespaceBefore && !whitespaceAfter) return;
			case AROUND:
				if (whitespaceBefore && whitespaceAfter) return;
		}

		logPos('Whitespace mode "$mode" violated by "${TokenDefPrinter.print(tok.tok)}"', tok.pos);
	}

	function checkContext(token:TokenTree):Bool {
		if (TokenTreeCheckUtils.isTypeParameter(token)) return false;
		if (TokenTreeCheckUtils.isImportMult(token)) return false;
		if (TokenTreeCheckUtils.filterOpSub(token)) return false;

		// TODO check contexts

		return true;
	}

	function hasContext(context:WhitespaceContext):Bool {
		return contexts.contains(context);
	}
}

@:enum
abstract WhitespaceMode(String) {
	var BEFORE = "before";
	var AFTER = "after";
	var AROUND = "around";
	var NONE = "none";
}

@:enum
abstract WhitespaceContext(String) {
	var OBJECT_DECL = "Object";
	var FUNCTION = "Function";
	var FIELD = "Field";
	var SWITCH = "Switch";
	var TRY_CATCH = "Switch";
	var ARRAY_ACCESS = "Array";
}

@:enum
abstract WhitespaceToken(String) {
	var ASSIGN = "Assign";
	var UNARY = "Unary";
	var COMPARE = "Compare";
	var ARITHMETIC = "Arithmetic";
	var BITWISE = "Bitwise";
	var BOOL = "Bool";
	var ARROW = "=>";
	var COMMA = ",";
	var SEMICOLON = ";";
	var POPEN = "(";
	var PCLOSE = ")";
	var BROPEN = "{";
	var BRCLOSE = "}";
	var BKOPEN = "[";
	var BKCLOSE = "]";
	var DBLDOT = ":";
	var DOT = ".";
	var INTERVAL = "...";
}