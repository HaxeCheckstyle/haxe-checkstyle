package checkstyle.checks.whitespace;

import checkstyle.utils.TokenTreeCheckUtils;

@ignore("base class for OperatorWhitespace and SeparatorWhitespace")
class WhitespaceCheckBase extends Check {

	public function new() {
		super(TOKEN);

		categories = [Category.STYLE, Category.CLARITY];
	}

	function checkTokens(root:TokenTree, tokens:Array<TokenDef>, policy:WhitespacePolicy) {
		if ((policy == null) || (policy == IGNORE)) return;
		var tokenList:Array<TokenTree> = root.filter(tokens, ALL);
		checkTokenList(tokenList, policy);
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

@:enum
abstract WhitespacePolicy(String) {
	var BEFORE = "before";
	var AFTER = "after";
	var AROUND = "around";
	var NONE = "none";
	var IGNORE = "ignore";
}

@:enum
abstract WhitespaceUnaryPolicy(String) {
	var INNER = "inner";
	var NONE = "none";
	var IGNORE = "ignore";
}