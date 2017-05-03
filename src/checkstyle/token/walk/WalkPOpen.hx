package checkstyle.token.walk;

class WalkPOpen {
	public static function walkPOpen(stream:TokenStream, parent:TokenTree):TokenTree {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		parent.addChild(pOpen);
		WalkPOpen.walkPOpenParts(stream, pOpen);
		pOpen.addChild(stream.consumeTokenDef(PClose));
		return pOpen;
	}

	public static function walkPOpenParts(stream:TokenStream, parent:TokenTree) {
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case POpen:
					WalkPOpen.walkPOpen(stream, parent);
				case BrOpen:
					WalkObjectDecl.walkObjectDecl(stream, parent);
				case BkOpen:
					WalkArrayAccess.walkArrayAccess(stream, parent);
				case PClose:
					break;
				case Sharp(_):
					WalkSharp.walkSharp(stream, parent, WalkPOpen.walkPOpenParts);
				case Comma:
					var comma:TokenTree = stream.consumeToken();
					parent.addChild(comma);
				default:
					WalkStatement.walkStatement(stream, parent);
			}
		}
	}
}