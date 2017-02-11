package checkstyle.token.walk;

class WalkQuestion {
	public static function walkQuestion(stream:TokenStream, parent:TokenTree) {
		var question:TokenTree = stream.consumeTokenDef(Question);
		parent.addChild(question);
		WalkStatement.walkStatement(stream, question);
	}
}