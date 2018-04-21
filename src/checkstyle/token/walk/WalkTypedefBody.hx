package checkstyle.token.walk;

class WalkTypedefBody {
	public static function walkTypedefBody(stream:TokenStream, parent:TokenTree) {
		if (stream.is(BrOpen)) {
			var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
			parent.addChild(openTok);
			var progress:TokenStreamProgress = new TokenStreamProgress(stream);
			while (progress.streamHasChanged()) {
				switch (stream.token()) {
					case BrClose: break;
					default:
						WalkFieldDef.walkFieldDef(stream, openTok);
				}
				if (stream.is(BrClose)) break;
				WalkFieldDef.walkFieldDef(stream, openTok);
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else walkTypedefAlias(stream, parent);
	}

	public static function walkTypedefAlias(stream:TokenStream, parent:TokenTree) {
		var newParent:TokenTree;
		if (stream.is(POpen)) {
			newParent = WalkPOpen.walkPOpen(stream, parent);
		}
		else {
			newParent = WalkTypeNameDef.walkTypeNameDef(stream, parent);
		}
		if (stream.is(Arrow)) {
			var arrowTok:TokenTree = stream.consumeTokenDef(Arrow);
			newParent.addChild(arrowTok);
			walkTypedefAlias(stream, arrowTok);
		}
	}
}