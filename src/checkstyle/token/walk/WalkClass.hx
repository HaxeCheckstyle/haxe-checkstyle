package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkClass {

	public static function walkClass(stream:TokenStream, parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		WalkComment.walkComment(stream, parent);
		var name:TokenTree = WalkTypeNameDef.walkTypeNameDef(stream, typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		if (stream.isSharp()) WalkSharp.walkSharp(stream, name);
		WalkExtends.walkExtends(stream, name);
		WalkImplements.walkImplements(stream, name);
		WalkComment.walkComment(stream, name);
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);

		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					WalkVar.walkVar(stream, block, tempStore);
					tempStore = [];
				case Kwd(KwdFunction):
					WalkFunction.walkFunction(stream, block, tempStore);
					tempStore = [];
				case Sharp(_):
					WalkSharp.walkSharp(stream, block);
				case At:
					tempStore.push(WalkAt.walkAt(stream));
				case BrClose: break;
				case Semicolon:
					block.addChild(stream.consumeToken());
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		for (tok in tempStore) block.addChild(tok);
		block.addChild(stream.consumeTokenDef(BrClose));
	}
}