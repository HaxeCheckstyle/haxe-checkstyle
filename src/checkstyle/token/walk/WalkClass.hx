package checkstyle.token.walk;

import checkstyle.token.TokenTreeAccessHelper;

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
					walkClassContinueAfterSharp(stream, parent);
				case At:
					tempStore.push(WalkAt.walkAt(stream));
				case BrClose: break;
				case Semicolon:
					parent.addChild(stream.consumeToken());
				case Kwd(KwdPublic), Kwd(KwdPrivate), Kwd(KwdStatic), Kwd(KwdInline), Kwd(KwdMacro), Kwd(KwdOverride), Kwd(KwdDynamic):
					tempStore.push(stream.consumeToken());
				case Comment(_), CommentLine(_):
					tempStore.push(stream.consumeToken());
				default:
					throw "invalid token tree structure";
			}
		}
		for (tok in tempStore) {
			switch (tok.tok) {
				case Comment(_), CommentLine(_): parent.addChild(tok);
				default: throw "invalid token tree structure";
			}
		}
	}

	static function walkClassContinueAfterSharp(stream:TokenStream, parent:TokenTree) {
		var brOpen:TokenTreeAccessHelper = TokenTreeAccessHelper
			.access(parent)
			.lastChild().is(Sharp("if"))
			.lastOf(Kwd(KwdFunction))
			.firstChild()
			.lastChild()
			.is(BrOpen);
		if (brOpen.token == null) return;
		if (brOpen.lastChild().is(BrClose).token != null) return;
		WalkBlock.walkBlockContinue(stream, parent);
	}
}