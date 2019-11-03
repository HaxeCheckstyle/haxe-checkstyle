package checkstyle.utils;

class PosHelper {
	/**
		make a position for AST based checks that only holds function signature
		@param field determine position for field
		@return Position position that holds function signature
	**/
	public static function makeFieldSignaturePosition(field:Field):Position {
		var pos:Position = {file: field.pos.file, min: field.pos.min, max: field.pos.max};
		switch (field.kind) {
			case FFun(fun):
				if (fun.expr != null) {
					pos.max = fun.expr.pos.min;
				}
			case FVar(_):
			case FProp(_):
		}
		return pos;
	}

	/**
		report function signature not body
		@param token function or var token
		@return Position token position without body
	**/
	public static function getReportPos(token:TokenTree):Position {
		var pos:Position = token.getPos();
		var body:Null<TokenTree> = token.access().firstChild().firstOf(POpen).token;
		if (body == null) return pos;
		body = body.nextSibling;
		if (body == null) return pos;
		switch (body.tok) {
			case BrOpen:
			case DblDot:
				body = body.nextSibling;
			default:
				return pos;
		}
		if (body == null) return pos;
		pos.max = body.pos.min;
		return pos;
	}
}