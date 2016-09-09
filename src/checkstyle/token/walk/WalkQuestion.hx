package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkQuestion {
	public static function walkQuestion(stream:TokenStream, parent:TokenTree) {
		var question:TokenTree = stream.consumeTokenDef(Question);
		parent.addChild(question);
		WalkStatement.walkStatement(stream, question);
	}
}