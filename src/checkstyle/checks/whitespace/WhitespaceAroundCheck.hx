package checkstyle.checks.whitespace;

import tokentree.utils.TokenTreeCheckUtils;

/**
	Checks that a token is surrounded by whitespace.
**/
@name("WhitespaceAround")
@desc("Checks that a token is surrounded by whitespace.")
class WhitespaceAroundCheck extends Check {
	/**
		supported list of tokens:
		",", ";", "(", ")", "[", "]", "{", "}", ":", ".", "=", "+", "-", "*", "/", "%", ">", "<", ">=", "<=", "==", "!=",
		"&", "|", "^", "&&", "||", "<<", ">>", ">>>", "+=", "-=", "*=", "/=", "%=", "<<=", ">>=", ">>>=", "|=", "&=",
		"^=", "...", "=>", "!", "++", "--",
	**/
	public var tokens:Array<String>;

	public function new() {
		super(TOKEN);
		tokens = [
			"=",
			"+",
			"-",
			"*",
			"/",
			"%",
			">",
			"<",
			">=",
			"<=",
			"==",
			"!=",
			"&",
			"|",
			"^",
			"&&",
			"||",
			"<<",
			">>",
			">>>",
			"+=",
			"-=",
			"*=",
			"/=",
			"%=",
			"<<=",
			">>=",
			">>>=",
			"|=",
			"&=",
			"^=",
			"=>"
		];

		categories = [Category.STYLE, Category.CLARITY];
	}

	function hasToken(token:String):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	override function actualRun() {
		var tokenList:Array<TokenTreeDef> = [];

		if (hasToken(",")) tokenList.push(Comma);
		if (hasToken(";")) tokenList.push(Semicolon);
		if (hasToken("(")) tokenList.push(POpen);
		if (hasToken(")")) tokenList.push(PClose);
		if (hasToken("[")) tokenList.push(BkOpen);
		if (hasToken("]")) tokenList.push(BkClose);
		if (hasToken("{")) tokenList.push(BrOpen);
		if (hasToken("}")) tokenList.push(BrClose);
		if (hasToken(":")) tokenList.push(DblDot);
		if (hasToken(".")) tokenList.push(Dot);

		if (hasToken("=")) tokenList.push(Binop(OpAssign));
		if (hasToken("+")) tokenList.push(Binop(OpAdd));
		if (hasToken("-")) tokenList.push(Binop(OpSub));
		if (hasToken("*")) tokenList.push(Binop(OpMult));
		if (hasToken("/")) tokenList.push(Binop(OpDiv));
		if (hasToken("%")) tokenList.push(Binop(OpMod));

		if (hasToken(">")) tokenList.push(Binop(OpGt));
		if (hasToken("<")) tokenList.push(Binop(OpLt));
		if (hasToken(">=")) tokenList.push(Binop(OpGte));
		if (hasToken("<=")) tokenList.push(Binop(OpLte));
		if (hasToken("==")) tokenList.push(Binop(OpEq));
		if (hasToken("!=")) tokenList.push(Binop(OpNotEq));

		if (hasToken("&")) tokenList.push(Binop(OpAnd));
		if (hasToken("|")) tokenList.push(Binop(OpOr));
		if (hasToken("^")) tokenList.push(Binop(OpXor));

		if (hasToken("&&")) tokenList.push(Binop(OpBoolAnd));
		if (hasToken("||")) tokenList.push(Binop(OpBoolOr));

		if (hasToken("<<")) tokenList.push(Binop(OpShl));
		if (hasToken(">>")) tokenList.push(Binop(OpShr));
		if (hasToken(">>>")) tokenList.push(Binop(OpUShr));

		if (hasToken("+=")) tokenList.push(Binop(OpAssignOp(OpAdd)));
		if (hasToken("-=")) tokenList.push(Binop(OpAssignOp(OpSub)));
		if (hasToken("*=")) tokenList.push(Binop(OpAssignOp(OpMult)));
		if (hasToken("/=")) tokenList.push(Binop(OpAssignOp(OpDiv)));
		if (hasToken("%=")) tokenList.push(Binop(OpAssignOp(OpMod)));
		if (hasToken("<<=")) tokenList.push(Binop(OpAssignOp(OpShl)));
		if (hasToken(">>=")) tokenList.push(Binop(OpAssignOp(OpShr)));
		if (hasToken(">>>=")) tokenList.push(Binop(OpAssignOp(OpUShr)));
		if (hasToken("|=")) tokenList.push(Binop(OpAssignOp(OpOr)));
		if (hasToken("&=")) tokenList.push(Binop(OpAssignOp(OpAnd)));
		if (hasToken("^=")) tokenList.push(Binop(OpAssignOp(OpXor)));

		if (hasToken("...")) tokenList.push(Binop(OpInterval));
		if (hasToken("=>")) tokenList.push(Binop(OpArrow));

		if (hasToken("!")) tokenList.push(Unop(OpNot));
		if (hasToken("++")) tokenList.push(Unop(OpIncrement));
		if (hasToken("--")) tokenList.push(Unop(OpDecrement));

		if (tokenList.length <= 0) return;
		checkTokens(tokenList);
	}

	@:access(tokentree.TokenTree)
	function checkTokens(tokenList:Array<TokenTreeDef>) {
		var root:TokenTree = checker.getTokenTree();
		var allTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (token.matchesAny(tokenList)) {
				return FoundGoDeeper;
			}
			return GoDeeper;
		});

		for (tok in allTokens) {
			if (isPosSuppressed(tok.pos)) continue;
			if (TokenTreeCheckUtils.isTypeParameter(tok)) continue;
			if (TokenTreeCheckUtils.isImportMult(tok)) continue;
			if (TokenTreeCheckUtils.filterOpSub(tok)) continue;

			var linePos:LinePos = checker.getLinePos(tok.pos.min);
			var line:Bytes = Bytes.ofString(checker.lines[linePos.line]);
			var before:String = line.sub(0, linePos.ofs).toString();
			var tokLen:Int = tok.toString().length;
			var offs:Int = linePos.ofs + tokLen;
			var after:String = line.sub(offs, line.length - offs).toString();

			if (!(~/^.*\s$/.match(before))) {
				logPos('No whitespace around "$tok"', tok.pos);
				continue;
			}
			if (!(~/^(\s.*|)$/.match(after))) {
				logPos('No whitespace around "$tok"', tok.pos);
				continue;
			}
		}
	}
}