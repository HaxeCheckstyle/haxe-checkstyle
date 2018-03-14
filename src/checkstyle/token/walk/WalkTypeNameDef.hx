package checkstyle.token.walk;

class WalkTypeNameDef {
	public static function walkTypeNameDef(stream:TokenStream, parent:TokenTree):TokenTree {
		WalkComment.walkComment(stream, parent);
		if (stream.is(BrOpen)) {
			WalkTypedefBody.walkTypedefBody(stream, parent);
			return parent.getFirstChild();
		}
		if (stream.is(Question)) {
			var questTok:TokenTree = stream.consumeTokenDef(Question);
			parent.addChild(questTok);
			parent = questTok;
		}
		var name:TokenTree;
		switch (stream.token()) {
			case Kwd(KwdMacro), Kwd(KwdExtern), Kwd(KwdNew):
				name = stream.consumeToken();
			case Const(_):
				name = stream.consumeConst();
			case Dollar(_):
				name = stream.consumeToken();
			case Sharp(_):
				WalkSharp.walkSharp(stream, parent, WalkStatement.walkStatement);
				if (!stream.hasMore()) return parent.getFirstChild();
				switch (stream.token()) {
					case Const(_):
						name = stream.consumeConst();
					default:
						return parent.getFirstChild();
				}
			default:
				name = stream.consumeToken();
		}
		parent.addChild(name);
		if (stream.is(Dot)) {
			var dot:TokenTree = stream.consumeTokenDef(Dot);
			name.addChild(dot);
			WalkTypeNameDef.walkTypeNameDef(stream, dot);
			return name;
		}
		if (stream.is(Binop(OpLt))) WalkLtGt.walkLtGt(stream, name);
		WalkComment.walkComment(stream, name);
		return name;
	}
}