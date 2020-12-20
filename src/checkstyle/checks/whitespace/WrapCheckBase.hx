package checkstyle.checks.whitespace;

import tokentree.utils.TokenTreeCheckUtils;

/**
	base class for OperatorWrap and SeparatorWrap
**/
@ignore("base class for OperatorWrap and SeparatorWrap")
class WrapCheckBase extends Check {
	/**
		list mof wrapping tokens
	**/
	public var tokens:Array<String>;

	/**
		policy for wrapping token
		- eol = wrapping token should be at end of line
		- nl = wrapping token should start a new line
	**/
	public var option:WrapCheckBaseOption;

	public function new() {
		super(TOKEN);
		option = EOL;
		categories = [Category.STYLE, Category.CLARITY];
	}

	function hasToken(token:String):Bool {
		return (tokens.length == 0 || tokens.contains(token));
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
			if (TokenTreeCheckUtils.isOpGtTypedefExtension(tok)) continue;
			if (TokenTreeCheckUtils.isTypeParameter(tok)) continue;
			if (TokenTreeCheckUtils.isImportMult(tok)) continue;
			if (TokenTreeCheckUtils.filterOpSub(tok)) continue;

			var linePos:LinePos = checker.getLinePos(tok.pos.min);
			var line:Bytes = Bytes.ofString(checker.lines[linePos.line]);
			var before:String = line.sub(0, linePos.ofs).toString();
			var tokLen:Int = tok.toString().length;
			var offs:Int = linePos.ofs + tokLen;
			var after:String = line.sub(offs, line.length - offs).toString();

			if (~/^\s*$/.match(before)) {
				if (option != NL) {
					logPos('Token "$tok" must be at the end of the line', tok.pos);
					continue;
				}
			}
			if (~/^\s*(\/\/.*|\/\*.*|)$/.match(after)) {
				if (option != EOL) {
					logPos('Token "$tok" must be on a new line', tok.pos);
				}
			}
		}
	}
}

/**
	policy for wrapping token
	- eol = wrapping token should be at end of line
	- nl = wrapping token should start a new line
**/
enum abstract WrapCheckBaseOption(String) {
	var EOL = "eol";
	var NL = "nl";
}