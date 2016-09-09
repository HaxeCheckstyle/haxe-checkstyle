package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkIf {
	/**
	 * Kwd(KwdIf)
	 *  |- POpen
	 *  |   |- expression
	 *  |   |- PClose
	 *  |- BrOpen
	 *  |   |- statement
	 *  |   |- statement
	 *  |   |- BrClose
	 *  |- Kwd(KwdElse)
	 *      |- BrOpen
	 *          |- statement
	 *          |- statement
	 *          |- BrClose
	 *
	 */
	public static function walkIf(stream:TokenStream, parent:TokenTree) {
		var ifTok:TokenTree = stream.consumeTokenDef(Kwd(KwdIf));
		parent.addChild(ifTok);
		// condition
		WalkPOpen.walkPOpen(stream, ifTok);
		if (stream.is(DblDot)) return;
		// if-expr
		WalkBlock.walkBlock(stream, ifTok);
		if (stream.is(Kwd(KwdElse))) {
			var elseTok:TokenTree = stream.consumeTokenDef(Kwd(KwdElse));
			ifTok.addChild(elseTok);
			// else-expr
			WalkBlock.walkBlock(stream, elseTok);
		}
	}
}