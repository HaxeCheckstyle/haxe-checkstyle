package checkstyle.checks.whitespace;

import checkstyle.checks.whitespace.WrapCheckBase.WrapCheckBaseOption;

/**
	Checks line wrapping with operators.
**/
@name("OperatorWrap")
@desc("Checks line wrapping with operators.")
class OperatorWrapCheck extends WrapCheckBase {
	public function new() {
		super();
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
			"...",
			"=>",
			"++",
			"--"
		];
	}

	override function actualRun() {
		var tokenList:Array<TokenTreeDef> = [];

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

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "option",
				values: [WrapCheckBaseOption.EOL, WrapCheckBaseOption.NL]
			}]
		}];
	}
}