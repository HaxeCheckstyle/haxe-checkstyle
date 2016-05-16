package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkTry {
	/**
	 * Kwd(KwdTry)
	 *  |- BrOpen
	 *  |   |- statement
	 *  |   |- statement
	 *  |   |- BrClose
	 *  |- Kwd(KwdCatch)
	 *  |   |- BrOpen
	 *  |       |- statement
	 *  |       |- statement
	 *  |       |- BrClose
	 *  |- Kwd(KwdCatch)
	 *      |- BrOpen
	 *          |- statement
	 *          |- statement
	 *          |- BrClose
	 *
	 */
	public static function walkTry(stream:TokenStream, parent:TokenTree) {
		var tryTok:TokenTree = stream.consumeTokenDef(Kwd(KwdTry));
		parent.addChild(tryTok);
		WalkBlock.walkBlock(stream, tryTok);
		while (stream.is(Kwd(KwdCatch))) {
			WalkTry.walkCatch(stream, tryTok);
		}
	}

	/**
	 * Kwd(KwdCatch)
	 *  |- BrOpen
	 *      |- statement
	 *      |- statement
	 *      |- BrClose
	 *
	 */
	static function walkCatch(stream:TokenStream, parent:TokenTree) {
		var catchTok:TokenTree = stream.consumeTokenDef(Kwd(KwdCatch));
		parent.addChild(catchTok);
		WalkPOpen.walkPOpen(stream, catchTok);
		WalkComment.walkComment(stream, catchTok);
		WalkBlock.walkBlock(stream, catchTok);
	}
}