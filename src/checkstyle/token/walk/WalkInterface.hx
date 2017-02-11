package checkstyle.token.walk;

class WalkInterface {
	public static function walkInterface(stream:TokenStream, parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		// add name
		var name:TokenTree = WalkTypeNameDef.walkTypeNameDef(stream, typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		WalkExtends.walkExtends(stream, name);
		WalkImplements.walkImplements(stream, name);
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);
		WalkInterface.walkInterfaceBody(stream, block);
		block.addChild(stream.consumeTokenDef(BrClose));
	}

	public static function walkInterfaceBody(stream:TokenStream, parent:TokenTree) {
		var tempStore:Array<TokenTree> = [];
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					WalkVar.walkVar(stream, parent, tempStore);
					tempStore = [];
				case Kwd(KwdFunction):
					WalkFunction.walkFunction(stream, parent, tempStore);
					tempStore = [];
				case Sharp(_):
					WalkSharp.walkSharp(stream, parent, WalkInterface.walkInterfaceBody);
				case At:
					tempStore.push(WalkAt.walkAt(stream));
				case BrClose: break;
				case Semicolon:
					parent.addChild(stream.consumeToken());
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		for (tok in tempStore) parent.addChild(tok);
	}
}