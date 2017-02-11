package checkstyle.token.walk;

class WalkObjectDecl {

	public static function walkObjectDecl(stream:TokenStream, parent:TokenTree) {
		var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
		parent.addChild(openTok);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			if (stream.is(BrClose)) break;
			if (stream.is(Comma)) {
				openTok.addChild(stream.consumeToken());
				continue;
			}
			if (stream.is(DblDot)) {
				openTok.addChild(stream.consumeToken());
			}
			WalkStatement.walkStatement(stream, openTok);
		}
		openTok.addChild(stream.consumeTokenDef(BrClose));
	}
}