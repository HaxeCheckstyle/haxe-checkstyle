package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkExtends {
	public static function walkExtends(stream:TokenStream, parent:TokenTree) {
		if (!stream.is(Kwd(KwdExtends))) return;
		var parentType:TokenTree = stream.consumeTokenDef(Kwd(KwdExtends));
		parent.addChild(parentType);
		WalkComment.walkComment(stream, parent);
		WalkTypeNameDef.walkTypeNameDef(stream, parentType);
		WalkComment.walkComment(stream, parent);
		WalkExtends.walkExtends(stream, parentType);
		WalkComment.walkComment(stream, parent);
	}
}