package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkLtGt {
	public static function walkLtGt(stream:TokenStream, parent:TokenTree) {
		var ltTok:TokenTree = stream.consumeTokenDef(Binop(OpLt));
		parent.addChild(ltTok);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Comma:
					var comma:TokenTree = stream.consumeTokenDef(Comma);
					ltTok.addChild(comma);
					WalkTypeNameDef.walkTypeNameDef(stream, ltTok);
					WalkFieldDef.walkFieldDef(stream, ltTok);
				case Binop(OpGt): break;
				case DblDot:
					var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
					ltTok.addChild(dblDot);
					WalkTypeNameDef.walkTypeNameDef(stream, ltTok);
				default:
					WalkFieldDef.walkFieldDef(stream, ltTok);
			}
		}
		ltTok.addChild(stream.consumeTokenDef(Binop(OpGt)));
	}
}