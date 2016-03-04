package token;

import haxeparser.HaxeLexer;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenTree;
import checkstyle.token.TokenStream;
import checkstyle.token.TokenTreeBuilder;

class TokenTreeBuilderTest extends haxe.unit.TestCase {

	public function testImports() {
		var builder:TestTokenTreeBuilder = newBuilder (TokenTreeBuilderTests.IMPORT);
		var root:TokenTree = new TokenTree(null, null);
		builder.testWalkPackageImport(root);
		builder.testWalkPackageImport(root);
		builder.testWalkPackageImport(root);
		builder.testWalkPackageImport(root);
		builder.testWalkPackageImport(root);
		checkStreamEmpty(builder);

		assertEquals(TokenTreeBuilderTests.IMPORT_GOLD, treeToString(root));
	}

	public function testAt() {
		var builder:TestTokenTreeBuilder = newBuilder (TokenTreeBuilderTests.AT_ANNOTATION);
		var root:TokenTree = new TokenTree(null, null);
		root.addChild(builder.testWalkAt());
		root.addChild(builder.testWalkAt());
		root.addChild(builder.testWalkAt());
		root.addChild(builder.testWalkAt());
		builder.getTokenStream().consumeToken(); // remove comment line
		checkStreamEmpty(builder);

		assertEquals(TokenTreeBuilderTests.AT_ANNOTATION_GOLD, treeToString(root));
	}

	public function testIf() {
		var builder:TestTokenTreeBuilder = newBuilder (TokenTreeBuilderTests.IF);
		var root:TokenTree = new TokenTree(null, null);
		builder.testWalkIf(root);
		builder.testWalkIf(root);
		builder.testWalkIf(root);
		builder.testWalkIf(root);
		checkStreamEmpty(builder);

		assertEquals(TokenTreeBuilderTests.IF_GOLD, treeToString(root));
	}

	function newBuilder(code:String):TestTokenTreeBuilder {
		return new TestTokenTreeBuilder(makeTokenStream(code));
	}

	function makeTokenStream(code:String):TokenStream {
		var tokens:Array<Token> = [];
		var lexer = new HaxeLexer(byte.ByteData.ofString(code), "TokenStream");
		var t:Token = lexer.token(HaxeLexer.tok);
		while (t.tok != Eof) {
			tokens.push(t);
			t = lexer.token(haxeparser.HaxeLexer.tok);
		}
		return new TokenStream(tokens);
	}

	function checkStreamEmpty(builder:TestTokenTreeBuilder) {
		var stream:TokenStream = builder.getTokenStream();
		assertFalse(stream.hasMore());
	}

	function treeToString(token:TokenTree, prefix:String = ""):String {
		var buf:StringBuf = new StringBuf();
		var tokDef:TokenDef = token.tok;
		if (tokDef != null) buf.add('$prefix${tokDef}\n');
		if (token.hasChilds()) {
			for (child in token.childs) {
				buf.add(treeToString(child, prefix + "  "));
			}
		}
		return buf.toString();
	}
}

class TokenTreeBuilderTests {
	public static inline var IMPORT:String = "
		package checkstyle.checks;
		import haxeparser.*;
		import checkstyle.TokenTree;
		import checkstyle.TokenStream;
		import checkstyle.TokenTreeBuilder;
	";
	public static inline var IMPORT_GOLD:String =
		'  Kwd(KwdPackage)\n' +
		'    Const(CIdent(checkstyle))\n' +
		'      Dot\n' +
		'        Const(CIdent(checks))\n' +
		'          Semicolon\n' +
		'  Kwd(KwdImport)\n' +
		'    Const(CIdent(haxeparser))\n' +
		'      Dot\n' +
		'        Binop(OpMult)\n' +
		'          Semicolon\n' +
		'  Kwd(KwdImport)\n' +
		'    Const(CIdent(checkstyle))\n' +
		'      Dot\n' +
		'        Const(CIdent(TokenTree))\n' +
		'          Semicolon\n' +
		'  Kwd(KwdImport)\n' +
		'    Const(CIdent(checkstyle))\n' +
		'      Dot\n' +
		'        Const(CIdent(TokenStream))\n' +
		'          Semicolon\n' +
		'  Kwd(KwdImport)\n' +
		'    Const(CIdent(checkstyle))\n' +
		'      Dot\n' +
		'        Const(CIdent(TokenTreeBuilder))\n' +
		'          Semicolon\n';

	public static inline var AT_ANNOTATION:String = '
		@SuppressWarnings("checkstyle:MagicNumber")
		@SuppressWarnings(["checkstyle:MagicNumber", "checkstyle:AvoidStarImport"])
		@:from
		@Before
		// EOF
	';
	public static inline var AT_ANNOTATION_GOLD:String =
		'  At\n' +
		'    Const(CIdent(SuppressWarnings))\n' +
		'      POpen\n' +
		'        Const(CString(checkstyle:MagicNumber))\n' +
		'        PClose\n' +
		'  At\n' +
		'    Const(CIdent(SuppressWarnings))\n' +
		'      POpen\n' +
		'        BkOpen\n' +
		'          Const(CString(checkstyle:MagicNumber))\n' +
		'            Comma\n' +
		'          Const(CString(checkstyle:AvoidStarImport))\n' +
		'          BkClose\n' +
		'        PClose\n' +
		'  At\n' +
		'    DblDot\n' +
		'      Const(CIdent(from))\n' +
		'  At\n' +
		'    Const(CIdent(Before))\n';

	public static inline var IF:String = '
		if (tokDef != null) return;
		if (tokDef != null)
			return;
		else
			throw "error";
		if (token.hasChilds()) {
			return token.childs;
		}
		if (token.hasChilds()) {
			return token.childs;
		}
		else {
			return [];
		}
	';
	public static inline var IF_GOLD:String =
		'  Kwd(KwdIf)\n' +
		'    POpen\n' +
		'      Const(CIdent(tokDef))\n' +
		'        Binop(OpNotEq)\n' +
		'          Kwd(KwdNull)\n' +
		'      PClose\n' +
		'    Kwd(KwdReturn)\n' +
		'      Semicolon\n' +
		'  Kwd(KwdIf)\n' +
		'    POpen\n' +
		'      Const(CIdent(tokDef))\n' +
		'        Binop(OpNotEq)\n' +
		'          Kwd(KwdNull)\n' +
		'      PClose\n' +
		'    Kwd(KwdReturn)\n' +
		'      Semicolon\n' +
		'    Kwd(KwdElse)\n' +
		'      Kwd(KwdThrow)\n' +
		'        Const(CString(error))\n' +
		'          Semicolon\n' +
		'  Kwd(KwdIf)\n' +
		'    POpen\n' +
		'      Const(CIdent(token))\n' +
		'        Dot\n' +
		'          Const(CIdent(hasChilds))\n' +
		'            POpen\n' +
		'              PClose\n' +
		'      PClose\n' +
		'    BrOpen\n' +
		'      Kwd(KwdReturn)\n' +
		'        Const(CIdent(token))\n' +
		'          Dot\n' +
		'            Const(CIdent(childs))\n' +
		'              Semicolon\n' +
		'      BrClose\n' +
		'  Kwd(KwdIf)\n' +
		'    POpen\n' +
		'      Const(CIdent(token))\n' +
		'        Dot\n' +
		'          Const(CIdent(hasChilds))\n' +
		'            POpen\n' +
		'              PClose\n' +
		'      PClose\n' +
		'    BrOpen\n' +
		'      Kwd(KwdReturn)\n' +
		'        Const(CIdent(token))\n' +
		'          Dot\n' +
		'            Const(CIdent(childs))\n' +
		'              Semicolon\n' +
		'      BrClose\n' +
		'    Kwd(KwdElse)\n' +
		'      BrOpen\n' +
		'        Kwd(KwdReturn)\n' +
		'          BkOpen\n' +
		'            BkClose\n' +
		'        Semicolon\n' +
		'        BrClose\n';
}

class TestTokenTreeBuilder extends TokenTreeBuilder {

	public function new(stream:TokenStream) {
		super(stream);
	}

	public function setTokenStream(stream:TokenStream) {
		this.stream = stream;
	}

	public function getTokenStream():TokenStream {
		return this.stream;
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