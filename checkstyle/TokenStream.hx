package checkstyle;

import haxe.macro.Expr;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

class TokenStream {
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
		if ((current < 0) || (current >= tokens.length)) return null;
		var token:Token = tokens[current];
		current++;
		return new TokenTree(token.tok, token.pos);
	}

	public function consumeConstIdent():TokenTree {
		switch (token()) {
			case Const(CIdent(_)): return consumeToken();
			default: throw "bad token";
		}
	}
	public function consumeTokenDef(tokenDef:TokenDef):TokenTree {
		if (is(tokenDef)) return consumeToken();
		throw "bad token";
	}

	public function is(tokenDef:TokenDef):Bool {
		if ((current < 0) || (current >= tokens.length)) return false;
		var token:Token = tokens[current];
		return Type.enumEq(tokenDef, token.tok);
	}

	public function token():TokenDef {
		if ((current < 0) || (current >= tokens.length)) return null;
		return tokens[current].tok;
	}

	public function rewind() {
		if (current <= 0) return;
		current--;
	}

	public function printRemain() {
		for (index in current...tokens.length) trace (tokens[index]);
	}
}