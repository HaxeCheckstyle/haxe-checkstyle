package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkFile {
	public static function walkFile(stream:TokenStream, parent:TokenTree) {
		var tempStore:Array<TokenTree> = [];
		while (stream.hasMore()) {
			switch (stream.token()) {
				case Kwd(KwdPackage), Kwd(KwdImport), Kwd(KwdUsing):
					for (stored in tempStore) parent.addChild(stored);
					tempStore = [];
					WalkPackageImport.walkPackageImport(stream, parent);
				case Sharp(_):
					WalkSharp.walkSharp(stream, parent, WalkFile.walkFile);
					if (!stream.hasMore()) return;
					switch (stream.token()) {
						case BrOpen:
							WalkBlock.walkBlock(stream, parent.children[parent.children.length - 1]);
						default:
					}
				case At:
					tempStore.push(WalkAt.walkAt(stream));
				case Comment(_), CommentLine(_):
					tempStore.push(stream.consumeToken());
				case Kwd(KwdClass), Kwd(KwdInterface), Kwd(KwdEnum), Kwd(KwdTypedef), Kwd(KwdAbstract):
					WalkType.walkType(stream, parent, tempStore);
					tempStore = [];
				default:
					tempStore.push(stream.consumeToken());
			}
		}
	}
}