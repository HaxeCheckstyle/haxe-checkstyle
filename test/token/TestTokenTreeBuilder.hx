package token;

import haxeparser.HaxeLexer;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenTree;
import checkstyle.token.TokenStream;
import checkstyle.token.TokenTreeBuilder;

class TestTokenTreeBuilder extends TokenTreeBuilder {

	public static function parseCode(code:String):TestTokenTreeBuilder {
		var builder:TestTokenTreeBuilder = new TestTokenTreeBuilder(makeTokenStream(code));
		var root:TokenTree = new TokenTree(null, null, -1);
		builder.walkFile(root);
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
		return new TokenStream(tokens);
	}

	public function new(stream:TokenStream) {
		super(stream);
	}

	public function setTokenStream(stream:TokenStream) {
		this.stream = stream;
	}

	public function getTokenStream():TokenStream {
		return this.stream;
	}

	public function isStreamEmpty():Bool {
		return !stream.hasMore();
	}

	public function testWalkFile(parent:TokenTree) {
		walkFile(parent);
	}

	public function testWalkType(parent:TokenTree, prefixes:Array<TokenTree>) {
		walkType(parent, prefixes);
	}

	public function testWalkAt():TokenTree {
		return walkAt();
	}

	public function testWalkClass(parent:TokenTree, prefixes:Array<TokenTree>) {
		walkClass(parent, prefixes);
	}

	public function testWalkInterface(parent:TokenTree, prefixes:Array<TokenTree>) {
		walkInterface(parent, prefixes);
	}

	public function testWalkAbstract(parent:TokenTree, prefixes:Array<TokenTree>) {
		walkAbstract(parent, prefixes);
	}

	public function testWalkTypedef(parent:TokenTree, prefixes:Array<TokenTree>) {
		walkTypedef(parent, prefixes);
	}

	public function testWalkEnum(parent:TokenTree, prefixes:Array<TokenTree>) {
		walkEnum(parent, prefixes);
	}

	public function testWalkExtends(parent:TokenTree) {
		walkExtends(parent);
	}

	public function testWalkImplements(parent:TokenTree) {
		walkImplements(parent);
	}

	public function testWalkVar(parent:TokenTree, prefixes:Array<TokenTree>) {
		walkVar(parent, prefixes);
	}

	public function testWalkFunction(parent:TokenTree, prefixes:Array<TokenTree>) {
		walkFunction(parent, prefixes);
	}

	public function testWalkTypeNameDef(parent:TokenTree):TokenTree {
		return walkTypeNameDef(parent);
	}

	public function testWalkLtGt(parent:TokenTree) {
		walkLtGt(parent);
	}

	public function testWalkStatement(parent:TokenTree) {
		walkStatement(parent);
	}

	public function testWalkPackageImport(parent:TokenTree) {
		walkPackageImport(parent);
	}

	public function testWalkBlock(parent:TokenTree) {
		walkBlock(parent);
	}

	public function testWalkObjectDecl(parent:TokenTree) {
		walkObjectDecl(parent);
	}

	public function testWalkPOpen(parent:TokenTree) {
		walkPOpen(parent);
	}

	public function testWalkArrayAccess(parent:TokenTree) {
		walkArrayAccess(parent);
	}

	public function testWalkIf(parent:TokenTree) {
		walkIf(parent);
	}

	public function testWalkSwitch(parent:TokenTree) {
		walkSwitch(parent);
	}

	public function testWalkCase(parent:TokenTree) {
		walkCase(parent);
	}

	public function testWalkCaseExpr(parent:TokenTree) {
		walkCaseExpr(parent);
	}

	public function testWalkTry(parent:TokenTree) {
		walkTry(parent);
	}

	public function testWalkCatch(parent:TokenTree) {
		walkCatch(parent);
	}

	public function testWalkWhile(parent:TokenTree) {
		walkWhile(parent);
	}

	public function testWalkFor(parent:TokenTree) {
		walkFor(parent);
	}

	public function testWalkForPOpen(parent:TokenTree) {
		walkForPOpen(parent);
	}

	public function testWalkSharp(parent:TokenTree) {
		walkSharp(parent);
	}

	public function testWalkSharpExpr(parent:TokenTree) {
		walkSharpExpr(parent);
	}
}