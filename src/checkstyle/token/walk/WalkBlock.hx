package checkstyle.token.walk;

class WalkBlock {
	/**
	 * BrOpen
	 *  |- statement
	 *  |- statement
	 *  |- BrClose
	 *
	 */
	public static function walkBlock(stream:TokenStream, parent:TokenTree) {
		var tempStore:Array<TokenTree> = [];
		var rewindPos:Int = stream.currentPos();
		while (stream.is(At)) tempStore.push(WalkAt.walkAt(stream));
		if (stream.is(BrOpen)) {
			var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
			parent.addChild(openTok);
			for (tok in tempStore) openTok.addChild(tok);

			var progress:TokenStreamProgress = new TokenStreamProgress(stream);
			while (progress.streamHasChanged()) {
				switch (stream.token()) {
					case BrClose: break;
					case Comma, BkClose, PClose:
						var child:TokenTree = stream.consumeToken();
						openTok.addChild(child);
					default: WalkStatement.walkStatement(stream, openTok);

				}
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else {
			stream.rewindTo(rewindPos);
			WalkStatement.walkStatement(stream, parent);
		}
	}
}