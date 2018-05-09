package checkstyle.token;

class TokenTreeAccessHelper {

	public var token:TokenTree;

	function new(tok:TokenTree) {
		token = tok;
	}

	public static function access(tok:TokenTree):TokenTreeAccessHelper {
		return new TokenTreeAccessHelper(tok);
	}

	public function firstChild():TokenTreeAccessHelper {
		if (token == null) return this;
		return new TokenTreeAccessHelper(token.getFirstChild());
	}

	public function lastChild():TokenTreeAccessHelper {
		if (token == null) return this;
		return new TokenTreeAccessHelper(token.getLastChild());
	}

	public function firstOf(tokenDef:TokenDef):TokenTreeAccessHelper {
		if (token == null) return this;
		if (token.children == null) return new TokenTreeAccessHelper(null);
		for (tok in token.children) {
			if (tok.is(tokenDef)) return new TokenTreeAccessHelper(tok);
		}
		return new TokenTreeAccessHelper(null);
	}

	public function lastOf(tokenDef:TokenDef):TokenTreeAccessHelper {
		if (token == null) return this;
		if (token.children == null) return new TokenTreeAccessHelper(null);
		var found:TokenTree = null;
		for (tok in token.children) {
			if (tok.is(tokenDef)) found = tok;
		}
		return new TokenTreeAccessHelper(found);
	}

	public function child(index:Int):TokenTreeAccessHelper {
		if (token == null) return this;
		if (token.children == null) return new TokenTreeAccessHelper(null);
		if (token.children.length <= index) return new TokenTreeAccessHelper(null);
		return new TokenTreeAccessHelper(token.children[index]);
	}

	public function is(tokenDef:TokenDef):TokenTreeAccessHelper {
		if (token == null) return this;
		if (token.is(tokenDef)) return this;
		return new TokenTreeAccessHelper(null);
	}
}