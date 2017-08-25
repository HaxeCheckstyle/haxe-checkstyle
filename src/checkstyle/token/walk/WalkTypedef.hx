package checkstyle.token.walk;

class WalkTypedef {
	public static function walkTypedef(stream:TokenStream, parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		var name:TokenTree = WalkTypeNameDef.walkTypeNameDef(stream, typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		var assign:TokenTree = stream.consumeTokenDef(Binop(OpAssign));
		name.addChild(assign);
		WalkTypedefBody.walkTypedefBody(stream, assign);
	}
}