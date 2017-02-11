package checkstyle.token.walk;

class WalkFor {
	/**
	 * Kwd(KwdFor)
	 *  |- POpen
	 *  |   |- Const(CIdent(_))
	 *  |   |   |- Kwd(KwdIn)
	 *  |   |       |- Const(CIdent(_)
	 *  |   |- PClose
	 *  |- BrOpen
	 *      |- statement
	 *      |- statement
	 *      |- BrClose
	 *
	 * Kwd(KwdFor)
	 *  |- POpen
	 *  |   |- Const(CIdent(_))
	 *  |   |   |- Kwd(KwdIn)
	 *  |   |       |- IntInterval(_)
	 *  |   |           |- Const(CInt(_))
	 *  |   |- PClose
	 *  |- BrOpen
	 *      |- statement
	 *      |- statement
	 *      |- BrClose
	 *
	 */
	public static function walkFor(stream:TokenStream, parent:TokenTree) {
		var forTok:TokenTree = stream.consumeTokenDef(Kwd(KwdFor));
		parent.addChild(forTok);
		WalkComment.walkComment(stream, forTok);
		WalkFor.walkForPOpen(stream, forTok);
		WalkComment.walkComment(stream, forTok);
		WalkBlock.walkBlock(stream, forTok);
	}

	/**
	 * POpen
	 *  |- Const(CIdent(_))
	 *  |   |- Kwd(KwdIn)
	 *  |       |- Const(CIdent(_)
	 *  |- PClose
	 *
	 * POpen
	 *  |- Const(CIdent(_))
	 *  |   |- Kwd(KwdIn)
	 *  |       |- IntInterval(_)
	 *  |           |- Const(CInt(_))
	 *  |- PClose
	 *
	 */
	static function walkForPOpen(stream:TokenStream, parent:TokenTree) {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		WalkComment.walkComment(stream, pOpen);
		var identifier:TokenTree = stream.consumeConstIdent();
		parent.addChild(pOpen);
		pOpen.addChild(identifier);
		WalkComment.walkComment(stream, identifier);
		var inTok:TokenTree = stream.consumeTokenDef(Kwd(KwdIn));
		identifier.addChild(inTok);
		WalkComment.walkComment(stream, inTok);
		WalkStatement.walkStatement(stream, inTok);
		WalkComment.walkComment(stream, pOpen);
		pOpen.addChild(stream.consumeTokenDef(PClose));
		WalkComment.walkComment(stream, parent);
		return;
	}
}