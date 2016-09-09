package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkImplements {
	public static function walkImplements(stream:TokenStream, parent:TokenTree) {
		if (!stream.is(Kwd(KwdImplements))) return;
		var interfacePart:TokenTree = stream.consumeTokenDef(Kwd(KwdImplements));
		parent.addChild(interfacePart);
		WalkComment.walkComment(stream, parent);
		WalkTypeNameDef.walkTypeNameDef(stream, interfacePart);
		WalkComment.walkComment(stream, parent);
		WalkImplements.walkImplements(stream, interfacePart);
		WalkComment.walkComment(stream, parent);
	}
}