package checkstyle.token.walk;

class WalkObjectDecl {

	public static function walkObjectDecl(stream:TokenStream, parent:TokenTree) {
		var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
		parent.addChild(openTok);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			if (stream.is(BrClose)) break;
			WalkStatement.walkStatement(stream, openTok);
			if (stream.is(BrClose)) break;

			var name:TokenTree = openTok.getLastChild();
			var dbldot:TokenTree = stream.consumeTokenDef(DblDot);
			name.addChild(dbldot);

			WalkStatement.walkStatement(stream, dbldot);
			if (stream.is(Comma)) {
				openTok.addChild(stream.consumeToken());
			}
		}
		openTok.addChild(stream.consumeTokenDef(BrClose));
	}
}