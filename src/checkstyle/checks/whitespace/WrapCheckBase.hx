package checkstyle.checks.whitespace;

import checkstyle.utils.TokenTreeCheckUtils;

@ignore("base class for OperatorWrap and SeparatorWrap")
class WrapCheckBase extends Check {

	public var tokens:Array<String>;
	public var option:WrapCheckBaseOption;

	public function new() {
		super(TOKEN);
		option = EOL;
		categories = [Category.STYLE, Category.CLARITY];
	}

	function hasToken(token:String):Bool {
		return (tokens.length == 0 || tokens.contains(token));
	}

	function checkTokens(tokenList:Array<TokenDef>) {
		var root:TokenTree = checker.getTokenTree();
		var allTokens:Array<TokenTree> = root.filter(tokenList, ALL);

		for (tok in allTokens) {
			if (isPosSuppressed(tok.pos)) continue;
			if (TokenTreeCheckUtils.isTypeParameter(tok)) continue;
			if (TokenTreeCheckUtils.isImportMult(tok)) continue;
			if (TokenTreeCheckUtils.filterOpSub(tok)) continue;

			var linePos:LinePos = checker.getLinePos(tok.pos.min);
			var line:String = checker.lines[linePos.line];
			var before:String = line.substr(0, linePos.ofs);
			var tokLen:Int = tok.toString().length;
			var after:String = line.substr(linePos.ofs + tokLen);

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

@:enum
abstract WrapCheckBaseOption(String) {
	var EOL = "eol";
	var NL = "nl";
}