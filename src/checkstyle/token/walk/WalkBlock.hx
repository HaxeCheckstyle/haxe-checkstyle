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
			if (isBrOpenObjectDecl(parent)) {
				WalkObjectDecl.walkObjectDecl(stream, parent);
				return;
			}
			var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
			parent.addChild(openTok);
			for (tok in tempStore) openTok.addChild(tok);

			var progress:TokenStreamProgress = new TokenStreamProgress(stream);
			while (progress.streamHasChanged()) {
				if (stream.is(BrClose)) break;
				WalkStatement.walkStatement(stream, openTok);
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else {
			stream.rewindTo(rewindPos);
			WalkStatement.walkStatement(stream, parent);
		}
	}

	static function isBrOpenObjectDecl(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return false;
		return switch (token.tok) {
			case BkOpen: true;
			case Kwd(KwdReturn): true;
			case Kwd(KwdFor): isBrOpenObjectDecl(token.parent);
			case Kwd(_): false;
			case Binop(OpAssign): true;
			default: isBrOpenObjectDecl(token.parent);
		}
	}
}