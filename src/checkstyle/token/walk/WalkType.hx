package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkType {
	public static function walkType(stream:TokenStream, parent:TokenTree, prefixes:Array<TokenTree>) {
		switch (stream.token()) {
			case Kwd(KwdClass):
				WalkClass.walkClass(stream, parent, prefixes);
			case Kwd(KwdInterface):
				WalkInterface.walkInterface(stream, parent, prefixes);
			case Kwd(KwdAbstract):
				WalkAbstract.walkAbstract(stream, parent, prefixes);
			case Kwd(KwdTypedef):
				WalkTypedef.walkTypedef(stream, parent, prefixes);
			case Kwd(KwdEnum):
				WalkEnum.walkEnum(stream, parent, prefixes);
			default:
		}
	}
}