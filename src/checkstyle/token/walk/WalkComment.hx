package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkComment {
	public static function walkComment(stream:TokenStream, parent:TokenTree) {
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Comment(_), CommentLine(_):
					var comment:TokenTree = stream.consumeToken();
					parent.addChild(comment);
				default:
					return;
			}
		}
	}
}