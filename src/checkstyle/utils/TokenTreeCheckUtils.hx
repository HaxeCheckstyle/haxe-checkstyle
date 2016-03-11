package checkstyle.utils;

import checkstyle.token.TokenTree;

class TokenTreeCheckUtils {

	public static function isImportMult(token:TokenTree):Bool {
		switch (token.tok) {
			case Binop(OpMult), Dot:
				var parent:TokenTree = token.parent;
				while (parent != null) {
					switch (parent.tok) {
						case Kwd(KwdMacro):
						case Kwd(KwdExtern):
						case Const(CIdent(_)):
						case Dot:
						case Kwd(KwdImport): return true;
						default: return false;
					}
					parent = parent.parent;
				}
				return false;
			default:
				return false;
		}
	}

	public static function isTypeParameter(token:TokenTree):Bool {
		switch (token.tok) {
			case Binop(OpGt):
				return token.parent.tok.match(Binop(OpLt));
			case Binop(OpLt):
				return token.getLastChild().tok.match(Binop(OpGt));
			default:
				return false;
		}
	}

	public static function filterOpSub(token:TokenTree):Bool {
		if (!token.tok.match(Binop(OpSub))) return false;
		return switch (token.parent.tok) {
			case Binop(_): true;
			case IntInterval(_): true;
			case BkOpen: true;
			case BrOpen: true;
			case POpen: true;
			case Question: true;
			case DblDot: true;
			case Kwd(KwdIf): true;
			case Kwd(KwdElse): true;
			case Kwd(KwdWhile): true;
			case Kwd(KwdDo): true;
			case Kwd(KwdFor): true;
			case Kwd(KwdReturn): true;
			default: false;
		}
	}
}