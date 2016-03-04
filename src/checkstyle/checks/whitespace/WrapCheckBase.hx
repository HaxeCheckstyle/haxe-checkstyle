package checkstyle.checks.whitespace;

import checkstyle.Checker.LinePos;
import checkstyle.LintMessage.SeverityLevel;
import checkstyle.token.TokenTree;
import haxeparser.Data;
import haxe.macro.Expr;

@ignore("base class for OperatorWrap and SeparatorWrap")
class WrapCheckBase extends Check {

	public static inline var EOL:String = "eol";
	public static inline var NL:String = "nl";

	public var tokens:Array<String>;
	public var option:String;

	public function new() {
		super();
		option = EOL;
	}

	function hasToken(token:String):Bool {
		if (tokens.length == 0) return true;
		if (tokens.indexOf(token) > -1) return true;
		return false;
	}

	function checkTokens(tokenList:Array<TokenDef>) {
		var root:TokenTree = checker.getTokenTree();
		var allTokens:Array<TokenTree> = root.filter(tokenList, ALL);

		for (tok in allTokens) {
			if (isPosSuppressed(tok.pos)) continue;

			var linePos:LinePos = checker.getLinePos(tok.pos.min);
			var line:String = checker.lines[linePos.line];
			var before:String = line.substr(0, linePos.ofs);
			var tokLen:Int = TokenDefPrinter.print(tok.tok).length;
			var after:String = line.substr(linePos.ofs + tokLen);

			if (~/^\s*$/.match(before)) {
				if (option != NL) {
					logPos('Token "${TokenDefPrinter.print(tok.tok)}" must be at the end of the line', tok.pos, Reflect.field(SeverityLevel, severity));
					continue;
				}
			}
			if (~/^\s*(\/\/.*|\/\*.*|)$/.match(after)) {
				if (option != EOL) {
					logPos('Token "${TokenDefPrinter.print(tok.tok)}" must on a new line', tok.pos, Reflect.field(SeverityLevel, severity));
				}
			}
		}
	}
}