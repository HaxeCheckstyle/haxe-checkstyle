package checkstyle.token;

import byte.ByteData;

import checkstyle.token.walk.WalkFile;

class TokenTreeBuilder {
	public static function buildTokenTree(tokens:Array<Token>, bytes:ByteData):TokenTree {
		var stream:TokenStream = new TokenStream(tokens, bytes);
		var root:TokenTree = new TokenTree(null, null, -1);
		WalkFile.walkFile(stream, root);
		return root;
	}
}