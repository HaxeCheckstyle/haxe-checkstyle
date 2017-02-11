package token;

import byte.ByteData;
import haxeparser.HaxeLexer;

import haxeparser.Data.Token;

import checkstyle.token.TokenTree;
import checkstyle.token.TokenStream;
import checkstyle.token.TokenTreeBuilder;

import checkstyle.token.walk.WalkFile;

class TestTokenTreeBuilder extends TokenTreeBuilder {

	public static function parseCode(code:String):TestTokenTreeBuilder {
		var builder:TestTokenTreeBuilder = new TestTokenTreeBuilder(code);
		var root:TokenTree = new TokenTree(null, null, -1);
		WalkFile.walkFile(builder.stream, root);
		return builder;
	}

	public static function makeTokenStream(code:String):TokenStream {
		var tokens:Array<Token> = [];
		var lexer = new HaxeLexer(byte.ByteData.ofString(code), "TokenStream");
		var t:Token = lexer.token(HaxeLexer.tok);
		while (t.tok != Eof) {
			tokens.push(t);
			t = lexer.token(haxeparser.HaxeLexer.tok);
		}
		return new TokenStream(tokens, ByteData.ofString(code));
	}

	var stream:TokenStream;

	public function new(code:String) {
		stream = makeTokenStream(code);
	}

	public function setTokenStream(newStream:TokenStream) {
		this.stream = newStream;
	}

	public function getTokenStream():TokenStream {
		return this.stream;
	}

	public function isStreamEmpty():Bool {
		return !stream.hasMore();
	}
}