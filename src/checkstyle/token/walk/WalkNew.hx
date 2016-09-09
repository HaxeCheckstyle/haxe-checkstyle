package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkNew {
	public static function walkNew(stream:TokenStream, parent:TokenTree) {
		var newTok:TokenTree = stream.consumeTokenDef(Kwd(KwdNew));
		parent.addChild(newTok);
		var name:TokenTree = WalkTypeNameDef.walkTypeNameDef(stream, newTok);
		WalkPOpen.walkPOpen(stream, name);
	}
}