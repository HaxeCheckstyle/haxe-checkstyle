package checkstyle.token.walk;

class WalkDoWhile {
	/**
	 * Kwd(KwdDo)
	 *  |- BrOpen
	 *  |   |- statement
	 *  |   |- statement
	 *  |   |- BrClose
	 *  |- Kwd(KwdWhile)
	 *      |- POpen
	 *      |   |- expression
	 *      |   |- PClose
	 *      |- Semicolon
	 *
	 */
	public static function walkDoWhile(stream:TokenStream, parent:TokenTree) {
		var doTok:TokenTree = stream.consumeTokenDef(Kwd(KwdDo));
		parent.addChild(doTok);
		WalkComment.walkComment(stream, doTok);
		WalkBlock.walkBlock(stream, doTok);
		var whileTok:TokenTree = stream.consumeTokenDef(Kwd(KwdWhile));
		doTok.addChild(whileTok);
		WalkPOpen.walkPOpen(stream, whileTok);
		WalkComment.walkComment(stream, whileTok);
		if (stream.is(Semicolon)) whileTok.addChild(stream.consumeToken());
	}
}