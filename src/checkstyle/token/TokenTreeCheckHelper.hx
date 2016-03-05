package checkstyle.token;

class TokenTreeCheckHelper {

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
				return switch (token.parent.tok) {
					case Binop(OpLt): true;
					default: false;
				}
			case Binop(OpLt):
				return switch (token.getLastChild().tok) {
					case Binop(OpGt): true;
					default: false;
				}
			default:
				return false;
		}
	}
}