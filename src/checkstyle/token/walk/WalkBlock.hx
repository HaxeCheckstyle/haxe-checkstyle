package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkBlock {
	/**
	 * BrOpen
	 *  |- statement
	 *  |- startement
	 *  |- BrClose
	 *
	 */

	public static function walkBlock(stream:TokenStream, parent:TokenTree) {
		if (stream.is(BrOpen)) {
			if (isArrayComprehension(parent)) {
				WalkObjectDecl.walkObjectDecl(stream, parent);
				return;
			}
			var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
			parent.addChild(openTok);
			var progress:TokenStreamProgress = new TokenStreamProgress(stream);
			while (progress.streamHasChanged()) {
				if (stream.is(BrClose)) break;
				WalkStatement.walkStatement(stream, openTok);
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else WalkStatement.walkStatement(stream, parent);
	}

	static function isArrayComprehension(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return false;
		return switch (token.tok) {
			case BkOpen: true;
			case Kwd(KwdTypedef): true;
			case Kwd(KwdReturn): true;
			default: isArrayComprehension(token.parent);
		}
	}
}