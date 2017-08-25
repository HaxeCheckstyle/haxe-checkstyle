package checkstyle.token.walk;

class WalkClass {

	public static function walkClass(stream:TokenStream, parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		WalkComment.walkComment(stream, parent);
		var name:TokenTree = WalkTypeNameDef.walkTypeNameDef(stream, typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		if (stream.isSharp()) WalkSharp.walkSharp(stream, name, WalkClass.walkClassExtends);
		WalkClass.walkClassExtends(stream, name);
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);
		WalkClass.walkClassBody(stream, block);
		block.addChild(stream.consumeTokenDef(BrClose));
	}

	public static function walkClassExtends(stream:TokenStream, name:TokenTree) {
		WalkExtends.walkExtends(stream, name);
		if (stream.isSharp()) WalkSharp.walkSharp(stream, name, WalkClass.walkClassExtends);
		WalkImplements.walkImplements(stream, name);
		if (stream.isSharp()) WalkSharp.walkSharp(stream, name, WalkClass.walkClassExtends);
		WalkComment.walkComment(stream, name);
	}

	public static function walkClassBody(stream:TokenStream, parent:TokenTree) {
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
					WalkSharp.walkSharp(stream, parent, WalkClass.walkClassBody);
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