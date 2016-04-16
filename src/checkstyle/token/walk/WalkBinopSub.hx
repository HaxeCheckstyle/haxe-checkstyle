package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkBinopSub {
	public static function walkBinopSub(stream:TokenStream, parent:TokenTree) {
		var sub:TokenTree = stream.consumeOpSub();
		parent.addChild(sub);
		switch (sub.tok) {
			case Const(_):
				WalkStatement.walkStatementContinue(stream, sub);
			default:
				WalkStatement.walkStatement(stream, sub);
		}
	}
}