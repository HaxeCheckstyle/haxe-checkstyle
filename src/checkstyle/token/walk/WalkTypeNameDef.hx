package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkTypeNameDef {
	public static function walkTypeNameDef(stream:TokenStream, parent:TokenTree):TokenTree {
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
			case Sharp(_):
				WalkSharp.walkSharp(stream, parent);
				return parent.getFirstChild();
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
		if (stream.is(Arrow)) {
			var arrow:TokenTree = stream.consumeTokenDef(Arrow);
			name.addChild(arrow);
			WalkTypeNameDef.walkTypeNameDef(stream, arrow);
		}
		return name;
	}
}