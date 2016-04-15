package token;

import haxe.PosInfos;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenTree;

class TokenTreeBuilderTest extends haxe.unit.TestCase {

	function assertTokenEquals(testCase:TokenTreeBuilderTests, actual:String, ?pos:PosInfos) {
		assertEquals((testCase:String), actual, pos);
	}

	public function testImports() {
		var builder:TestTokenTreeBuilder = newBuilder(TokenTreeBuilderTests.IMPORT);
		var root:TokenTree = new TokenTree(null, null, -1);
		builder.testWalkPackageImport(root);
		builder.testWalkPackageImport(root);
		builder.testWalkPackageImport(root);
		builder.testWalkPackageImport(root);
		builder.testWalkPackageImport(root);
		checkStreamEmpty(builder);

		assertTokenEquals(IMPORT_GOLD, treeToString(root));
	}

	public function testAt() {
		var builder:TestTokenTreeBuilder = newBuilder(TokenTreeBuilderTests.AT_ANNOTATION);
		var root:TokenTree = new TokenTree(null, null, -1);
		root.addChild(builder.testWalkAt());
		root.addChild(builder.testWalkAt());
		root.addChild(builder.testWalkAt());
		root.addChild(builder.testWalkAt());
		builder.getTokenStream().consumeToken(); // remove comment line
		checkStreamEmpty(builder);

		assertTokenEquals(AT_ANNOTATION_GOLD, treeToString(root));
	}

	public function testIf() {
		var builder:TestTokenTreeBuilder = newBuilder(TokenTreeBuilderTests.IF);
		var root:TokenTree = new TokenTree(null, null, -1);
		builder.testWalkIf(root);
		builder.testWalkIf(root);
		builder.testWalkIf(root);
		builder.testWalkIf(root);
		checkStreamEmpty(builder);

		assertTokenEquals(IF_GOLD, treeToString(root));
	}

	function newBuilder(code:String):TestTokenTreeBuilder {
		return new TestTokenTreeBuilder(TestTokenTreeBuilder.makeTokenStream(code));
	}

	function checkStreamEmpty(builder:TestTokenTreeBuilder) {
		assertTrue(builder.isStreamEmpty());
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

@:enum
abstract TokenTreeBuilderTests(String) to String {
	var IMPORT = "
		package checkstyle.checks;

		import haxeparser.*;
		import checkstyle.TokenTree;
		import checkstyle.TokenStream;
		import checkstyle.TokenTreeBuilder;
	";
	var IMPORT_GOLD =
	"  Kwd(KwdPackage)\n" +
	"    Const(CIdent(checkstyle))\n" +
	"      Dot\n" +
	"        Const(CIdent(checks))\n" +
	"          Semicolon\n" +
	"  Kwd(KwdImport)\n" +
	"    Const(CIdent(haxeparser))\n" +
	"      Dot\n" +
	"        Binop(OpMult)\n" +
	"          Semicolon\n" +
	"  Kwd(KwdImport)\n" +
	"    Const(CIdent(checkstyle))\n" +
	"      Dot\n" +
	"        Const(CIdent(TokenTree))\n" +
	"          Semicolon\n" +
	"  Kwd(KwdImport)\n" +
	"    Const(CIdent(checkstyle))\n" +
	"      Dot\n" +
	"        Const(CIdent(TokenStream))\n" +
	"          Semicolon\n" +
	"  Kwd(KwdImport)\n" +
	"    Const(CIdent(checkstyle))\n" +
	"      Dot\n" +
	"        Const(CIdent(TokenTreeBuilder))\n" +
	"          Semicolon\n";

	var AT_ANNOTATION = '
		@SuppressWarnings("checkstyle:MagicNumber")
		@SuppressWarnings(["checkstyle:MagicNumber", "checkstyle:AvoidStarImport"])
		@:from
		@Before
		// EOF
	';
	var AT_ANNOTATION_GOLD =
	"  At\n" +
	"    Const(CIdent(SuppressWarnings))\n" +
	"      POpen\n" +
	"        Const(CString(checkstyle:MagicNumber))\n" +
	"        PClose\n" +
	"  At\n" +
	"    Const(CIdent(SuppressWarnings))\n" +
	"      POpen\n" +
	"        BkOpen\n" +
	"          Const(CString(checkstyle:MagicNumber))\n" +
	"          Comma\n" +
	"          Const(CString(checkstyle:AvoidStarImport))\n" +
	"          BkClose\n" +
	"        PClose\n" +
	"  At\n" +
	"    DblDot\n" +
	"      Const(CIdent(from))\n" +
	"  At\n" +
	"    Const(CIdent(Before))\n";

	var IF = '
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
	var IF_GOLD =
	"  Kwd(KwdIf)\n" +
	"    POpen\n" +
	"      Const(CIdent(tokDef))\n" +
	"        Binop(OpNotEq)\n" +
	"          Kwd(KwdNull)\n" +
	"      PClose\n" +
	"    Kwd(KwdReturn)\n" +
	"      Semicolon\n" +
	"  Kwd(KwdIf)\n" +
	"    POpen\n" +
	"      Const(CIdent(tokDef))\n" +
	"        Binop(OpNotEq)\n" +
	"          Kwd(KwdNull)\n" +
	"      PClose\n" +
	"    Kwd(KwdReturn)\n" +
	"      Semicolon\n" +
	"    Kwd(KwdElse)\n" +
	"      Kwd(KwdThrow)\n" +
	"        Const(CString(error))\n" +
	"          Semicolon\n" +
	"  Kwd(KwdIf)\n" +
	"    POpen\n" +
	"      Const(CIdent(token))\n" +
	"        Dot\n" +
	"          Const(CIdent(hasChilds))\n" +
	"            POpen\n" +
	"              PClose\n" +
	"      PClose\n" +
	"    BrOpen\n" +
	"      Kwd(KwdReturn)\n" +
	"        Const(CIdent(token))\n" +
	"          Dot\n" +
	"            Const(CIdent(childs))\n" +
	"              Semicolon\n" +
	"      BrClose\n" +
	"  Kwd(KwdIf)\n" +
	"    POpen\n" +
	"      Const(CIdent(token))\n" +
	"        Dot\n" +
	"          Const(CIdent(hasChilds))\n" +
	"            POpen\n" +
	"              PClose\n" +
	"      PClose\n" +
	"    BrOpen\n" +
	"      Kwd(KwdReturn)\n" +
	"        Const(CIdent(token))\n" +
	"          Dot\n" +
	"            Const(CIdent(childs))\n" +
	"              Semicolon\n" +
	"      BrClose\n" +
	"    Kwd(KwdElse)\n" +
	"      BrOpen\n" +
	"        Kwd(KwdReturn)\n" +
	"          BkOpen\n" +
	"            BkClose\n" +
	"          Semicolon\n" +
	"        BrClose\n";
}