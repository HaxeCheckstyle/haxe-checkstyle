package checkstyle.checks.whitespace;

import checkstyle.Checker.LinePos;
import checkstyle.token.TokenTree;
import checkstyle.checks.whitespace.WhitespaceCheckBase.WhitespacePolicy;
import haxeparser.Data;

@name("SeparatorWhitespace")
@desc("Checks that whitespace is present or absent around a separators.")
class SeparatorWhitespaceCheck extends WhitespaceCheckBase {

	// .
	public var dotPolicy:WhitespacePolicy;
	// ,
	public var commaPolicy:WhitespacePolicy;
	// ;
	public var semicolonPolicy:WhitespacePolicy;

	public function new() {
		super();
		dotPolicy = NONE;
		commaPolicy = AFTER;
		semicolonPolicy = AFTER;

		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();

		checkTokens(root, [Dot], dotPolicy);
		checkTokens(root, [Comma], commaPolicy);
		checkTokens(root, [Semicolon], semicolonPolicy);
	}

	override function violation(tok:TokenTree, policy:String) {
		if (isWrapped(tok, cast (policy, WhitespacePolicy))) return;
		logPos('SeparatorWhitespace policy "$policy" violated by "$tok"', tok.pos);
	}

	function isWrapped(tok:TokenTree, policy:WhitespacePolicy):Bool {
		if (tok.tok.match(Semicolon)) return false;
		if (policy == AROUND) return false;

		var index:Int = tok.index;
		var tokPos:LinePos = checker.getLinePos(tok.pos.min);

		var prevTok:Token = checker.tokens[index - 1];
		var nextTok:Token = checker.tokens[index + 1];
		var prevTokPos:LinePos = checker.getLinePos(prevTok.pos.max);
		var nextTokPos:LinePos = checker.getLinePos(nextTok.pos.min);

		var wrapBefore:Bool = prevTokPos.line != tokPos.line;
		var wrapAfter:Bool = tokPos.line != nextTokPos.line;

		switch (policy) {
			case AFTER:
				if (wrapBefore) return true;
			case BEFORE:
				if (wrapAfter) return true;
			case NONE:
				if (wrapBefore || wrapAfter) return true;
			default:
		}
		return false;
	}
}