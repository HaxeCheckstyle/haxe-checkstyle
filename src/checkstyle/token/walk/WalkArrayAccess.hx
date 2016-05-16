package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkArrayAccess {
	public static function walkArrayAccess(stream:TokenStream, parent:TokenTree) {
		var bkOpen:TokenTree = stream.consumeTokenDef(BkOpen);
		parent.addChild(bkOpen);
		var tempStore:Array<TokenTree> = [];
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdFor):
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					WalkFor.walkFor(stream, bkOpen);
				case Kwd(KwdWhile):
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					WalkWhile.walkWhile(stream, bkOpen);
				case POpen:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					WalkPOpen.walkPOpen(stream, bkOpen);
				case BrOpen:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					WalkObjectDecl.walkObjectDecl(stream, bkOpen);
				case BkOpen:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					WalkArrayAccess.walkArrayAccess(stream, bkOpen);
				case BkClose:
					break;
				case At:
					tempStore.push(WalkAt.walkAt(stream));
				case Kwd(KwdFunction):
					WalkFunction.walkFunction(stream, bkOpen, tempStore);
					tempStore = [];
				case Comma:
					var comma:TokenTree = stream.consumeTokenDef(Comma);
					bkOpen.addChild(comma);
				default:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					WalkStatement.walkStatement(stream, bkOpen);
			}
		}
		bkOpen.addChild(stream.consumeTokenDef(BkClose));
	}
}