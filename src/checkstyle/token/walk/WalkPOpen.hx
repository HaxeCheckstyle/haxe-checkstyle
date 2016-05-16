package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkPOpen {
	public static function walkPOpen(stream:TokenStream, parent:TokenTree) {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		parent.addChild(pOpen);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case POpen:
					WalkPOpen.walkPOpen(stream, pOpen);
				case BrOpen:
					WalkObjectDecl.walkObjectDecl(stream, pOpen);
				case BkOpen:
					WalkArrayAccess.walkArrayAccess(stream, pOpen);
				case PClose:
					break;
				case Sharp(_):
					WalkSharp.walkSharp(stream, pOpen);
				case Comma:
					var comma:TokenTree = stream.consumeToken();
					pOpen.addChild(comma);
				default:
					WalkStatement.walkStatement(stream, pOpen);
			}
		}
		pOpen.addChild(stream.consumeTokenDef(PClose));
	}
}