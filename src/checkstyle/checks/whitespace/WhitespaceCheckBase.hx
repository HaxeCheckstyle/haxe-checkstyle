package checkstyle.checks.whitespace;

import tokentree.utils.TokenTreeCheckUtils;

/**
	base class for OperatorWhitespace and SeparatorWhitespace
**/
@ignore("base class for OperatorWhitespace and SeparatorWhitespace")
class WhitespaceCheckBase extends Check {
	public function new() {
		super(TOKEN);

		categories = [Category.STYLE, Category.CLARITY];
	}

	@:access(tokentree.TokenTree)
	function checkTokens(root:TokenTree, tokens:Array<TokenTreeDef>, policy:WhitespacePolicy) {
		if ((policy == null) || (policy == IGNORE)) return;
		var tokenList:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			if (token.matchesAny(tokens)) {
				return FoundGoDeeper;
			}
			return GoDeeper;
		});
		checkTokenList(tokenList, policy);
	}

	function checkTokenList(tokens:Array<TokenTree>, policy:WhitespacePolicy) {
		for (token in tokens) {
			if (isPosSuppressed(token.pos)) continue;
			if (TokenTreeCheckUtils.isImportMult(token)) continue;
			if (TokenTreeCheckUtils.isTypeParameter(token)) continue;
			if (TokenTreeCheckUtils.filterOpSub(token)) continue;
			checkWhitespace(token, adjustPolicy(token, policy));
		}
	}

	function adjustPolicy(token:TokenTree, policy:WhitespacePolicy):WhitespacePolicy {
		return policy;
	}

	function checkWhitespace(tok:TokenTree, policy:WhitespacePolicy) {
		checkWhitespaceExt(tok, function(before:Bool, after:Bool) {
			switch (policy) {
				case BEFORE:
					if (before && !after) return;
				case AFTER:
					if (!before && after) return;
				case NONE:
					if (!before && !after) return;
				case AROUND:
					if (before && after) return;
				default:
					return;
			}
			violation(tok, Std.string(policy));
		});
	}

	function checkUnaryWhitespace(tok:TokenTree, policy:WhitespaceUnaryPolicy) {
		var leftSide:Bool = TokenTreeCheckUtils.isUnaryLeftSided(tok);
		checkWhitespaceExt(tok, function(before:Bool, after:Bool) {
			switch (policy) {
				case INNER:
					if (leftSide && after) return;
					if (!leftSide && before) return;
				case NONE:
					if (leftSide && !after) return;
					if (!leftSide && !before) return;
				default:
					return;
			}
			violation(tok, Std.string(policy));
		});
	}

	function checkWhitespaceExt(tok:TokenTree, checkCallback:WhitespacePolicyCheck) {
		var linePos:LinePos = checker.getLinePos(tok.pos.min);
		var tokLen:Int = tok.toString().length;
		if (tok.tok.match(IntInterval(_))) {
			linePos = checker.getLinePos(tok.pos.max - 3);
			tokLen = 3;
		}
		var line:Bytes = Bytes.ofString(checker.lines[linePos.line]);
		var before:String = line.sub(0, linePos.ofs).toString();
		var offs:Int = linePos.ofs + tokLen;
		var after:String = line.sub(offs, line.length - offs).toString();

		var whitespaceBefore:Bool = ~/^(.*\s|)$/.match(before);
		var whitespaceAfter:Bool = ~/^(\s.*|)$/.match(after);

		checkCallback(whitespaceBefore, whitespaceAfter);
	}

	function violation(tok:TokenTree, policy:String) {}
}

typedef WhitespacePolicyCheck = Bool -> Bool -> Void;

/**
	policy for whitespace
	- around = enforce whitespace before and after operator
	- before = enforce whitespace before and no whitespace after operator
	- after = enforce no whitespace before and whitespace after operator
	- none = enforce no whitespace before and after operator
	- ignore = skip checks
**/
enum abstract WhitespacePolicy(String) {
	var BEFORE = "before";
	var AFTER = "after";
	var AROUND = "around";
	var NONE = "none";
	var IGNORE = "ignore";
}

/**
	policy for whitespace
	- inner = enforce whitespace between unary operator and operand
	- none = enforce no whitespace between unary operator and operand
	- ignore = skip checks
**/
enum abstract WhitespaceUnaryPolicy(String) {
	var INNER = "inner";
	var NONE = "none";
	var IGNORE = "ignore";
}