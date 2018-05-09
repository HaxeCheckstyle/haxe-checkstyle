package checkstyle.token.walk;

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
				case PClose, BrClose, BkClose, Semicolon, Comma:
					parent.addChild(stream.consumeToken());
				case Kwd(KwdExtern), Kwd(KwdPrivate), Kwd(KwdPublic):
					tempStore.push(stream.consumeToken());
				default:
					WalkBlock.walkBlock(stream, parent);
			}
		}
		for (stored in tempStore) {
			switch (stored.tok) {
				case Kwd(KwdExtern), Kwd(KwdPrivate), Kwd(KwdPublic), At: throw "invalid token tree structure";
				default: parent.addChild(stored);
			}
		}
	}
}