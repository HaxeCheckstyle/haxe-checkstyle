package checkstyle;

import haxe.macro.Expr;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

class TokenStream {
	public static inline var NO_MORE_TOKENS:String = "no more tokens";

	var tokens:Array<Token>;
	var current:Int;

	public function new(tokens:Array<Token>) {
		this.tokens = tokens;
		current = 0;
	}

	public function hasMore():Bool {
		return current < tokens.length;
	}

	public function consumeToken():TokenTree {
		if ((current < 0) || (current >= tokens.length)) throw NO_MORE_TOKENS;
		var token:Token = tokens[current];
		current++;
		return new TokenTree(token.tok, token.pos);
	}

	public function consumeConstIdent():TokenTree {
		switch (token()) {
			case Const(CIdent(_)): return consumeToken();
			default: throw 'bad token ${token()} != Const(CIdent(_))';
		}
	}

	public function consumeConst():TokenTree {
		switch (token()) {
			case Const(_): return consumeToken();
			default: throw 'bad token ${token()} != Const(_)';
		}
	}

	public function consumeTokenDef(tokenDef:TokenDef):TokenTree {
		if (is(tokenDef)) return consumeToken();
		throw 'bad token ${token()} != $tokenDef';
	}

	public function is(tokenDef:TokenDef):Bool {
		if ((current < 0) || (current >= tokens.length)) throw NO_MORE_TOKENS;
		var token:Token = tokens[current];
		return Type.enumEq(tokenDef, token.tok);
	}

	public function token():TokenDef {
		if ((current < 0) || (current >= tokens.length)) throw NO_MORE_TOKENS;
		return tokens[current].tok;
	}

	public function rewind() {
		if (current <= 0) return;
		current--;
	}

	/**
	 * HaxeLexer does not handle '>=', '>>', '>>=' and '>>>=' it produces an
	 * individual token for each character.
	 * This function provides a workaround, which scans the tokens following a
	 * Binop(OpGt) and if it is followed by Binop(OpAssign) or Binop(OpGt),
	 * it returns the correct token:
	 * '>' -> Binop(OpGt)
	 * '>=' -> Binop(OpGte)
	 * '>>' -> Binop(OpShr)
	 * '>>=' -> Binop(OpAssignOp(OpShr))
	 * '>>>=' -> Binop(OpAssignOp(OpUShr))
	 *
	 */
	public function consumeOpGt():TokenTree {
		var tok:TokenTree = consumeTokenDef(Binop(OpGt));
		switch (token()) {
			case Binop(OpGt):
				return consumeOpShr(tok);
			case Binop(OpAssign):
				var assignTok:TokenTree = consumeTokenDef(Binop(OpAssign));
				return new TokenTree(Binop(OpGte), {
						file:tok.pos.file,
						min:tok.pos.min,
						max:assignTok.pos.max
					});
			default:
				return tok;
		}
	}

	function consumeOpShr(parent:Token):TokenTree {
		var tok:TokenTree = consumeTokenDef(Binop(OpGt));
		switch (token()) {
			case Binop(OpGt):
				var innerGt:TokenTree = consumeTokenDef(Binop(OpGt));
				var assignTok:TokenTree = consumeTokenDef(Binop(OpAssign));
				return new TokenTree(Binop(OpAssignOp(OpUShr)), {
						file:parent.pos.file,
						min:parent.pos.min,
						max:assignTok.pos.max
					});
			case Binop(OpAssign):
				var assignTok:TokenTree = consumeTokenDef(Binop(OpAssign));
				return new TokenTree(Binop(OpAssignOp(OpShr)), {
						file:parent.pos.file,
						min:parent.pos.min,
						max:assignTok.pos.max
					});
			default:
				return new TokenTree(Binop(OpShr), {
						file:parent.pos.file,
						min:parent.pos.min,
						max:tok.pos.max
					});
		}
	}

	/**
	 * HaxeLexer does not detect negative Const(CInt(_)) or Const(CFloat(_))
	 * This function provides a workaround, which scans the tokens around
	 * Binop(OpSub) to see if the token stream should contain a negative const
	 * value and returns a proper Const(CInt(-x)) or Const(CFloat(-x)) token
	 *
	 */
	public function consumeOpSub():TokenTree {
		var tok:Token = consumeTokenDef(Binop(OpSub));
		switch (token()) {
			case Const(CInt(_)), Const(CFloat(_)):
			default:
				return new TokenTree(tok.tok, tok.pos);
		}
		var previous:Int = current - 2;
		if (previous < 0) throw NO_MORE_TOKENS;
		var prevTok:Token = tokens[previous];
		switch (prevTok.tok) {
			case Binop(_), Unop(_), BkOpen, POpen, Comma, DblDot, IntInterval(_), Question:
			default:
				return new TokenTree(tok.tok, tok.pos);
		}
		switch (token()) {
			case Const(CInt(n)):
				var const:TokenTree = consumeConst();
				return new TokenTree(Const(CInt('-$n')), {
						file:tok.pos.file,
						min:tok.pos.min,
						max:const.pos.max
					});
			case Const(CFloat(n)):
				var const:TokenTree = consumeConst();
				return new TokenTree(Const(CFloat('-$n')), {
						file:tok.pos.file,
						min:tok.pos.min,
						max:const.pos.max
					});
			default:
				throw NO_MORE_TOKENS;
		}
	}

	public function printRemain() {
		for (index in current...tokens.length) trace (tokens[index]);
	}
}