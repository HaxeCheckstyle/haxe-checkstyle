package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkFunction {
	public static function walkFunction(stream:TokenStream, parent:TokenTree, prefixes:Array<TokenTree>) {
		var funcTok:TokenTree = stream.consumeTokenDef(Kwd(KwdFunction));
		parent.addChild(funcTok);
		WalkComment.walkComment(stream, funcTok);

		var name:TokenTree = funcTok;
		switch (stream.token()) {
			case Kwd(KwdNew):
				name = WalkTypeNameDef.walkTypeNameDef(stream, funcTok);
			case POpen:
			case Binop(OpLt):
				WalkLtGt.walkLtGt(stream, funcTok);
				name = funcTok.getLastChild();
			default:
				name = WalkTypeNameDef.walkTypeNameDef(stream, funcTok);
		}
		for (stored in prefixes) name.addChild(stored);
		WalkComment.walkComment(stream, name);
		WalkFunction.walkFunctionParameters(stream, name);
		WalkComment.walkComment(stream, name);
		if (stream.is(DblDot)) {
			var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
			name.addChild(dblDot);
			WalkTypeNameDef.walkTypeNameDef(stream, dblDot);
		}
		WalkBlock.walkBlock(stream, name);
	}

	static function walkFunctionParameters(stream:TokenStream, parent:TokenTree) {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		parent.addChild(pOpen);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			if (stream.is(PClose)) break;
			WalkFieldDef.walkFieldDef(stream, pOpen);
		}
		pOpen.addChild(stream.consumeTokenDef(PClose));
	}
}