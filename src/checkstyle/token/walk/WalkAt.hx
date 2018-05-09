package checkstyle.token.walk;

class WalkAt {
	/**
	 * At
	 *  |- DblDot
	 *      |- Const(CIdent)
	 *          |- POpen
	 *              |- expression
	 *              |- PClose
	 *
	 * At
	 *  |- DblDot
	 *      |- Const(CIdent)
	 *
	 * At
	 *  |- Const(CIdent)
	 *      |- POpen
	 *          |- expression
	 *          |- PClose
	 *
	 * At
	 *  |- Const(CIdent)
	 *
	 */
	public static function walkAt(stream:TokenStream):TokenTree {
		var atTok:TokenTree = stream.consumeTokenDef(At);
		var parent:TokenTree = atTok;
		if (stream.is(DblDot)) {
			var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
			atTok.addChild(dblDot);
			parent = dblDot;
		}
		var name:TokenTree;
		switch (stream.token()) {
			case Const(_):
				name = stream.consumeConstIdent();
			default:
				name = stream.consumeToken();
		}
		parent.addChild(name);
		if (stream.is(POpen)) WalkPOpen.walkPOpen(stream, name);
		return atTok;
	}

	public static function walkAts(stream:TokenStream):Array<TokenTree> {
		var tempStore:Array<TokenTree> = [];
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case At: tempStore.push(WalkAt.walkAt(stream));
				default:
			}
		}
		return tempStore;
	}
}