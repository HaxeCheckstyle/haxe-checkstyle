package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkWhile {
	/**
	 * Kwd(KwdWhile)
	 *  |- POpen
	 *  |   |- expression
	 *  |   |- PClose
	 *  |- BrOpen
	 *      |- statement
	 *      |- statement
	 *      |- BrClose
	 *
	 */
	public static function walkWhile(stream:TokenStream, parent:TokenTree) {
		var whileTok:TokenTree = stream.consumeTokenDef(Kwd(KwdWhile));
		parent.addChild(whileTok);
		WalkComment.walkComment(stream, whileTok);
		WalkPOpen.walkPOpen(stream, whileTok);
		WalkComment.walkComment(stream, whileTok);
		WalkBlock.walkBlock(stream, whileTok);
	}
}