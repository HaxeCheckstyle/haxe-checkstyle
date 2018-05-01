package token.verify;

// import haxe.PosInfos;

import massive.munit.Assert;

import haxeparser.Data;

import checkstyle.token.TokenTree;

import checkstyle.token.walk.WalkFile;

import token.TokenTreeBuilderParsingTest.TokenTreeBuilderParsingTests;

class VerifyTokenTreeTest {

	@Test
	public function testImport() {
		var root:IVerifyTokenTree = buildTokenTree(VerifyTokenTreeTests.IMPORT);

		root.first().is(Kwd(KwdPackage)).count(1).filter(Const(CIdent("checkstyle"))).count(1).childs().is(Dot).childs().childs().is(Semicolon);

		root.filter(Kwd(KwdImport)).count(4).filter(Const(CIdent("checkstyle"))).count(3).childs().is(Dot).childs().childs().count(3).is(Semicolon);
		root.filter(Kwd(KwdImport)).count(4).filter(Const(CIdent("haxeparser"))).count(1).childs().is(Dot).childs().childs().count(1).is(Semicolon);

		root.last().is(Kwd(KwdUsing)).filter(Const(CIdent("checkstyle"))).count(1).childs().is(Dot).childs().childs().count(1).is(Semicolon);
	}

	@Test
	public function testObjectDecl() {
		var root:IVerifyTokenTree = buildTokenTree(TokenTreeBuilderParsingTests.BLOCK_OBJECT_DECL_SAMPLES_ISSUE_396_1);

		// class
		var block:IVerifyTokenTree = root.childFirst().is(Kwd(KwdClass)).count(1).childFirst().is(Const(CIdent("Test"))).childFirst().is(BrOpen).childCount(2);
		block.childLast().is(BrClose).noChilds();

		// function test()
		var func:IVerifyTokenTree = block.childFirst().is(Kwd(KwdFunction)).childFirst().is(Const(CIdent("test"))).childCount(2);
		func.childFirst().is(POpen).childFirst().is(PClose).noChilds();

		// function body
		block = func.last().is(BrOpen).childCount(3);
		block.childFirst().is(CommentLine("fails with: bad token Comma != BrClose")).noChilds();
		block.last().is(BrClose).noChilds();

		// var test = switch a
		var eq:IVerifyTokenTree = block.childAt(1).is(Kwd(KwdVar)).childs().count(1).is(Const(CIdent("test"))).childs().count(1).is(Binop(OpAssign));
		var sw:IVerifyTokenTree = eq.childs().count(1).is(Kwd(KwdSwitch)).childCount(2);
		sw.childFirst().is(Const(CIdent("a"))).noChilds();

		// switch body
		block = sw.childLast().is(BrOpen).childCount(3);

		// case 3
		var cas:IVerifyTokenTree = block.childFirst().is(Kwd(KwdCase)).childCount(2);
		cas.childFirst().is(Const(CInt("3"))).noChilds();
		cas = cas.childLast().is(DblDot).childs().count(2);
		cas.last().is(Semicolon).noChilds();
		cas = cas.first().is(BrOpen).childCount(4).childs();
		cas.first().is(Const(CIdent("a"))).childs().count(1).is(DblDot).childs().count(1).is(Const(CInt("1"))).noChilds();
		cas.at(1).is(Comma).noChilds();
		cas.at(2).is(Const(CIdent("b"))).childs().count(1).is(DblDot).childs().count(1).is(Const(CInt("2"))).noChilds();
		cas.last().is(BrClose).noChilds();

		//default
		cas = block.childAt(1).is(Kwd(KwdDefault)).childs().is(DblDot).childs().count(2);
		cas.last().is(Semicolon).noChilds();
		cas = cas.first().is(BrOpen).childCount(4).childs();
		cas.first().is(Const(CIdent("a"))).childs().count(1).is(DblDot).childs().count(1).is(Const(CInt("0"))).noChilds();
		cas.at(1).is(Comma).noChilds();
		cas.at(2).is(Const(CIdent("b"))).childs().count(1).is(DblDot).childs().count(1).is(Const(CInt("2"))).noChilds();
		cas.last().is(BrClose).noChilds();

		block.childLast().is(BrClose).noChilds();
	}

	@Test
	public function testTypedefComments() {
		var root:IVerifyTokenTree = buildTokenTree(TokenTreeBuilderParsingTests.TYPEDEF_COMMENTS);

		// typedef CheckFile
		var type:IVerifyTokenTree = root.childFirst().is(Kwd(KwdTypedef)).oneChild().childFirst().is(Const(CIdent("CheckFile")));
		var brOpen:IVerifyTokenTree = type.childFirst().is(Binop(OpAssign)).oneChild().childFirst().is(BrOpen).childCount(8);
		brOpen.childAt(0).is(CommentLine(" °"));

		// var name:String;
		var v:IVerifyTokenTree = brOpen.childAt(1).is(Kwd(KwdVar)).oneChild().childFirst().is(Const(CIdent("name"))).childCount(2);
		v.childFirst().is(DblDot).oneChild().childFirst().is(Const(CIdent("String"))).noChilds();
		v.childLast().is(Semicolon).noChilds();

		brOpen.childAt(2).is(CommentLine(" öäü")).noChilds();

		// var content:String;
		v = brOpen.childAt(3).is(Kwd(KwdVar)).oneChild().childFirst().is(Const(CIdent("content"))).childCount(2);
		v.childFirst().is(DblDot).oneChild().childFirst().is(Const(CIdent("String"))).noChilds();
		v.childLast().is(Semicolon).noChilds();

		brOpen.childAt(4).is(CommentLine(" €łµ")).noChilds();

		// var index:Int;
		v = brOpen.childAt(5).is(Kwd(KwdVar)).oneChild().childFirst().is(Const(CIdent("index"))).childCount(2);
		v.childFirst().is(DblDot).oneChild().childFirst().is(Const(CIdent("Int"))).noChilds();
		v.childLast().is(Semicolon).noChilds();

		brOpen.childAt(6).is(CommentLine(" æ@ð")).noChilds();
		brOpen.childLast().is(BrClose).noChilds();
	}

	function buildTokenTree(content:String):IVerifyTokenTree {
		var builder:TestTokenTreeBuilder = new TestTokenTreeBuilder(content);
		var root:TokenTree = new TokenTree(null, null, -1);
		WalkFile.walkFile(builder.getTokenStream(), root);
		Assert.isTrue(builder.isStreamEmpty());
		return new VerifyTokenTree(root);
	}
}

@:enum
abstract VerifyTokenTreeTests(String) to String {
	var IMPORT = "
		package checkstyle.checks;

		import haxeparser.*;
		import checkstyle.TokenTree;,
		import checkstyle.TokenStream;
		import checkstyle.TokenTreeBuilder;
		using checkstyle.TokenTree;
	";
}