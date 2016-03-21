package checkstyle.utils;

import checkstyle.token.TokenTree;

class TokenTreeCheckUtils {

	public static function isImportMult(token:TokenTree):Bool {
		return switch (token.tok) {
			case Binop(OpMult), Dot: isImport(token.parent);
			default: false;
		}
	}

	public static function isImport(token:TokenTree):Bool {
		var parent:TokenTree = token;
		while (parent != null) {
			if (parent.tok == null) return false;
			switch (parent.tok) {
				case Kwd(KwdMacro):
				case Kwd(KwdExtern):
				case Const(CIdent(_)):
				case Dot:
				case Kwd(KwdIn):
				case Kwd(KwdImport): return true;
				default: return false;
			}
			parent = parent.parent;
		}
		return false;
	}

	public static function isTypeParameter(token:TokenTree):Bool {
		return switch (token.tok) {
			case Binop(OpGt): token.parent.tok.match(Binop(OpLt));
			case Binop(OpLt): token.getLastChild().tok.match(Binop(OpGt));
			default: false;
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

	public static function isUnaryLeftSided(tok:TokenTree):Bool {
		var child:TokenTree = tok.getFirstChild();

		if (child == null) return false;
		return switch (child.tok) {
			case Const(_): true;
			case POpen: true;
			default: false;
		}
	}

	public static function isTernary(tok:TokenTree):Bool {
		if (!tok.tok.match(Question)) return false;
		if (!tok.getLastChild().tok.match(DblDot)) return false;
		return true;
	}
}