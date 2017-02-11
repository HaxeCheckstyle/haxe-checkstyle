package checkstyle.token.walk;

class WalkAbstract {
	public static function walkAbstract(stream:TokenStream, parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		var name:TokenTree = WalkTypeNameDef.walkTypeNameDef(stream, typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		if (stream.is(POpen)) WalkPOpen.walkPOpen(stream, name);
		var typeParent:TokenTree = name;
		var typeChild:TokenTree;
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case BrOpen: break;
				case Const(CIdent("from")), Const(CIdent("to")):
					var fromToken:TokenTree = stream.consumeToken();
					name.addChild(fromToken);
					WalkTypeNameDef.walkTypeNameDef(stream, fromToken);
				default:
					typeChild = stream.consumeToken();
					typeParent.addChild(typeChild);
					typeParent = typeChild;
			}
		}
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);
		WalkAbstract.walkAbstractBody(stream, block);
		block.addChild(stream.consumeTokenDef(BrClose));
	}

	public static function walkAbstractBody(stream:TokenStream, parent:TokenTree) {
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
					WalkSharp.walkSharp(stream, parent, WalkAbstract.walkAbstractBody);
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