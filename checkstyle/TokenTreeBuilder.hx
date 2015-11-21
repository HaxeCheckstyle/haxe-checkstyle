package checkstyle;

import sys.io.File;

import haxe.macro.Expr;

import haxeparser.HaxeLexer;
import haxeparser.*;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

class TokenTreeBuilder {

	var stream:TokenStream;

	function new(stream:TokenStream) {
		this.stream = stream;
	}

	public static function buildTokenTree(tokens:Array<Token>):TokenTree {

		var tokenizer:TokenTreeBuilder = new TokenTreeBuilder(new TokenStream(tokens));

		var root:TokenTree = new TokenTree(null, null);
		//walkTokens(root);
		tokenizer.walkFile(root);
		//trace (root);
		return root;
	}

	function walkFile(parent:TokenTree) {
		var newChild:TokenTree = null;
		var tempStore:Array<TokenTree> = [];
		while (stream.hasMore()) {
			switch (stream.token()) {
				case Kwd(KwdPackage), Kwd(KwdImport), Kwd(KwdUsing):
					for (stored in tempStore) parent.addChild(stored);
					tempStore = [];
					walkPackageImport(parent);
				case At:
					newChild = stream.consumeTokenDef(At);
					var name:TokenTree = stream.consumeConstIdent();
					newChild.addChild(name);
					if (stream.is(POpen)) walkPOpen(name);
					tempStore.push(newChild);
				case Kwd(KwdClass), Kwd(KwdInterface), Kwd(KwdMacro), Kwd(KwdEnum), Kwd(KwdTypedef), Kwd(KwdAbstract):
					walkType(parent, tempStore);
				default:
					tempStore.push(stream.consumeToken());
			}
		}
	}
	function walkType(parent:TokenTree, prefixes:Array<TokenTree>) {
		var newChild:TokenTree = stream.consumeToken();
		// add keyword (class, interface, abstract, macro, typedef, enum)
		parent.addChild(newChild);
		parent = newChild;
		// add name
		walkTypeNameDef(parent);
		// add all comments, annotations
		for (prefix in prefixes) newChild.addChild(prefix);
		switch (parent.tok) {
			case Kwd(KwdClass):
				walkClass(newChild);
			case Kwd(KwdInterface):
				walkInterface(newChild);
			case Kwd(KwdAbstract):
				walkAbstract(newChild);
			case Kwd(KwdTypedef):
				walkTypedef(newChild);
			case Kwd(KwdEnum):
				walkEnum(newChild);
			default:
		}
	}

	function walkClass(parent:TokenTree) {
		var newChild:TokenTree;
		if (stream.is(Kwd(KwdExtends))) {
			newChild = stream.consumeToken();
			parent.addChild(newChild);
			walkTypeNameDef(newChild);
		}
		if (stream.is(Kwd(KwdImplements))) {
			newChild = stream.consumeToken();
			parent.addChild(newChild);
			var interfaceParts:TokenTree;
			while (true) {
				walkTypeNameDef(newChild);
				if (stream.is(Comma)) {
					newChild.addChild(stream.consumeToken());
					continue;
				}
				break;
			}
		}
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		parent.addChild(block);

		while (stream.hasMore()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					walkVar(block, tempStore);
				case Kwd(KwdFunction):
					walkMethod(block, tempStore);
				case At:
					newChild = stream.consumeTokenDef(At);
					var name:TokenTree = stream.consumeConstIdent();
					newChild.addChild(name);
					if (stream.is(POpen)) walkPOpen(name);
					tempStore.push(newChild);
				case BrClose: break;
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		block.addChild(stream.consumeTokenDef(BrClose));
	}

	function walkVar(parent:TokenTree, prefixes:Array<TokenTree>) {
		var name:TokenTree;
		var varTok:TokenTree = stream.consumeTokenDef(Kwd(KwdVar));
		parent.addChild(varTok);
		name = stream.consumeConstIdent();
		varTok.addChild(name);
		for (stored in prefixes) name.addChild(stored);
		var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
		name.addChild(dblDot);
		walkTypeNameDef(dblDot);
		if (stream.is(Binop(OpAssign))) {
			walkStatement(name);
			return;
		}
		name.addChild(stream.consumeTokenDef(Semicolon));
	}

	//function walkNestedType(parent:TokenTree) {
	//    var ltTok:TokenTree = stream.consumeTokenDef(Binop(OpLt));
	//    switch (stream.token()) {
	//        case Binop(OpEq):
	//            walkStatement(name);
	//        case Binop(OpAssign):
	//            walkStatement(name);
	//        case Binop(OpLt):
	//            walkNestedType(name);
	//        default:
	//            name.addChild(stream.consumeTokenDef(Semicolon));
	//    }

	//    ltTok.addChild(stream.consumeTokenDef(Binop(OpGt)));
	//}

	function walkMethod(parent:TokenTree, prefixes:Array<TokenTree>) {
		var funcTok:TokenTree = stream.consumeTokenDef(Kwd(KwdFunction));
		var name:TokenTree;
		parent.addChild(funcTok);
		if (stream.is(Kwd(KwdNew))) {
			name = stream.consumeToken();
		}
		else {
			name = stream.consumeConstIdent();
		}
		//trace (name);
		funcTok.addChild(name);
		for (stored in prefixes) name.addChild(stored);
		walkPOpen(name);
		if (stream.is(DblDot)) {
			var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
			name.addChild(dblDot);
			walkTypeNameDef(name);
		}
		walkBlock(name);
	}

	function walkTypeNameDef(parent:TokenTree) {
		var name:TokenTree;
		name = stream.consumeConstIdent();
		parent.addChild(name);
		if (!stream.is(Binop(OpLt))) return;
		// TODO <> handling!!!
		var ltTok:TokenTree = stream.consumeTokenDef(Binop(OpLt));
		while(true) {
			switch (stream.token()) {
				case Comma:
					var comma:TokenTree = stream.consumeTokenDef(Comma);
					ltTok.addChild (comma);
					walkTypeNameDef(ltTok);
				case Binop(OpGt): break;
				default:
					walkTypeNameDef(ltTok);
			}
		}
		ltTok.addChild(stream.consumeTokenDef(Binop(OpGt)));
	}

	function walkInterface(parent:TokenTree) {
		// TODO write walker function
	}

	function walkAbstract(parent:TokenTree) {
		// TODO write walker function
	}

	function walkTypedef(parent:TokenTree) {
		// TODO write walker function
	}

	function walkEnum(parent:TokenTree) {
		// TODO write walker function
	}

	function walkStatement(parent:TokenTree) {
		var newChild:TokenTree = null;
		//if (stream.is(PClose)) return;
		switch (stream.token()) {
			case POpen:
				walkPOpen(parent);
			case BrOpen:
				walkBlock(parent);
				return;
			case BkOpen:
				walkArrayAccess(parent);
				return;
			case BrClose:
				return;
			case Sharp(_):
				walkSharp(parent);
				return;
			default:
		}
		newChild = stream.consumeToken();
		parent.addChild(newChild);
		switch (newChild.tok) {
			case Kwd(KwdFunction):
				walkFunction(newChild);
			//case Kwd(KwdVar), Kwd(KwdNew):
			//    walkTokens(newChild, Semicolon);
			//case Kwd(KwdReturn):
			//    walkStatement(newChild);
			//case Const(_):
				//walkTokens(newChild, Semicolon);
				//if (stopAt == Semicolon) return;
			//case Const(CIdent(_)):
				//if (stream.is(POpen)) return walkTokens(newChild, Semicolon);
			//case BrOpen:
			//    walkBlock(newChild);
			//case BkOpen:
			//    walkTokens(newChild, BkClose);
			//case POpen:
			//    walkTokens(newChild, PClose);
				//return;
			case Kwd(KwdIf):
				walkIf(newChild);
			case Kwd(KwdSwitch):
				walkSwitch(newChild);
			case Kwd(KwdCase):
				walkCase(newChild);
			case Kwd(KwdDefault):
				walkCase(newChild);
			case Kwd(KwdElse):
				walkBlock(newChild);
			case Kwd(KwdFor), Kwd(KwdWhile):
				walkFor(newChild);
			case Comment(_), CommentLine(_):
				return;
			case Comma:
				return;
			case Semicolon:
				return;
			case BrClose, BkClose, PClose:
				return;
			default:
				walkStatement(newChild);
		}
		return;
	}

	function walkTokens(parent:TokenTree, ?stopAt:TokenDef) {
		var newChild:TokenTree = null;
		while (stream.hasMore()) {
			newChild = stream.consumeToken();
			parent.addChild(newChild);
			if ((stopAt != null) && (Type.enumEq(stopAt, newChild.tok))) {
				return;
			}

			switch (newChild.tok) {
				//case Kwd(KwdPackage), Kwd(KwdImport):
				//    walkPackageImport(newChild);
				//case Kwd(KwdClass), Kwd(KwdInterface):
				//    walkTokens(newChild);
				case Kwd(KwdFunction):
					walkFunction(newChild);
				case Kwd(KwdVar), Kwd(KwdNew):
					walkTokens(newChild, Semicolon);
				case Kwd(KwdReturn):
					walkTokens(newChild, Semicolon);
					if (stopAt == Semicolon) return;
				case Const(_):
					//walkTokens(newChild, Semicolon);
					//if (stopAt == Semicolon) return;
				//case Const(CIdent(_)):
					//if (stream.is(POpen)) return walkTokens(newChild, Semicolon);
				case BrOpen:
					walkTokens(newChild, BrClose);
					return;
				case BkOpen:
					walkTokens(newChild, BkClose);
					return;
				case POpen:
					walkTokens(newChild, PClose);
					//return;
				case Kwd(KwdIf):
					walkIf(newChild);
				case Kwd(KwdSwitch):
					walkSwitch(newChild);
				case Kwd(KwdCase):
					walkCase(newChild);
				case Kwd(KwdDefault):
					walkCase(newChild);
				case Kwd(KwdElse):
					walkBlock(newChild);
					return;
				case Kwd(KwdFor), Kwd(KwdWhile):
					walkFor(newChild);
				case Semicolon:
				case BrClose, BkClose, PClose:
					return;
				default:
			}
			if (!stream.hasMore()) return;
			switch (stream.token()) {
				case BrOpen:
					//return walkTokens(newChild, stopAt);
				case BrOpen, BkOpen, POpen:
					//return walkTokens(newChild, stopAt);
				default:
					//return walkTokens(newChild, stopAt);
			}
		}
		return;
	}

	function walkPackageImport(parent:TokenTree) {
		var newChild:TokenTree = null;
		newChild = stream.consumeToken();
		parent.addChild(newChild);
		if (Type.enumEq(Semicolon, newChild.tok)) return;
		walkPackageImport(newChild);
	}

	function walkBlock(parent:TokenTree) {
		if (stream.is(BrOpen)) {
			var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
			//trace (openTok);
			parent.addChild(openTok);
			while (true) {
				if (stream.is(BrClose)) break;
				walkStatement(openTok);
				//trace (openTok);
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else walkStatement(parent);
	}

	function walkCaseBlock(parent:TokenTree) {
		while(true) {
			switch (stream.token()) {
				case Kwd(KwdCase): return;
				case Kwd(KwdDefault): return;
				case BrClose: return;
				default: walkStatement(parent);
			}
		}
	}

	function walkFunction(parent:TokenTree) {
		var newChild:TokenTree = null;
		switch (stream.token()) {
			case Const(CIdent(_)):
				newChild = stream.consumeToken();
				parent.addChild(newChild);
			default:
		}
		walkPOpen(parent);
		var prevChild:TokenTree = parent;
		while (!stream.is(BrOpen)) {
			newChild = stream.consumeToken();
			prevChild.addChild(newChild);
			prevChild = newChild;
		}
		walkBlock(parent);
	}

	function walkPOpen(parent:TokenTree) {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		parent.addChild(pOpen);
		while (true) {
			if (stream.is(POpen)) walkPOpen(pOpen);
			if (stream.is(BrOpen)) walkBlock(pOpen);
			if (stream.is(BkOpen)) walkArrayAccess(pOpen);
			if (stream.is(PClose)) break;
			pOpen.addChild(stream.consumeToken());
			//walkStatement(pOpen);
		}
		pOpen.addChild(stream.consumeTokenDef(PClose));
	}

	function walkArrayAccess(parent:TokenTree) {
		var bkOpen:TokenTree = stream.consumeTokenDef(BkOpen);
		parent.addChild(bkOpen);
		while (true) {
			//trace (stream.token());
			if (stream.is(POpen)) walkPOpen(bkOpen);
			if (stream.is(BrOpen)) walkBlock(bkOpen);
			if (stream.is(BkOpen)) walkArrayAccess(bkOpen);
			if (stream.is(BkClose)) break;
			bkOpen.addChild(stream.consumeToken());
			//walkStatement(pOpen);
		}
		bkOpen.addChild(stream.consumeTokenDef(BkClose));
	}

	function walkIf(parent:TokenTree) {
		// condition
		walkPOpen(parent);
		// if-expr
		walkBlock(parent);
		if (stream.is(Kwd(KwdElse))) {
			// else-expr
			walkStatement(parent);
		}
	}

	function walkSwitch(parent:TokenTree) {
		walkPOpen(parent);
		if (stream.is(Kwd(KwdCase))) return;
		walkBlock(parent);
	}

	function walkCase(parent:TokenTree) {
		walkTokens(parent, DblDot);

		var newChild:TokenTree = null;
		while(stream.hasMore()) {
			switch (stream.token()) {
				case Kwd(KwdCase), Kwd(KwdDefault), BrClose: return;
				case BrOpen: walkTokens(parent);
				//case Comment(_), CommentLine(_):
				//    newChild = stream.consumeToken();
				//    parent.addChild(newChild);
				default:
					walkStatement(parent);
			}
		}
	}

	function walkFor(parent:TokenTree) {
		walkPOpen(parent);
		walkBlock(parent);
	}

	function walkSharp(parent:TokenTree) {
		switch (stream.token()) {
			case Sharp("if"), Sharp("elseif"):
				var ifToken:TokenTree = stream.consumeToken();
				parent.addChild(ifToken);
				walkSharpExpr(ifToken);
			case Sharp("else"), Sharp("end"):
				parent.addChild(stream.consumeToken());
			case Sharp(_):
				parent.addChild(stream.consumeToken());
			default:
		}
	}

	function walkSharpExpr(parent:TokenTree) {
		var childToken:TokenTree;
		while (true) {
			switch (stream.token()) {
				case Unop(OpNot):
					childToken = stream.consumeToken();
					parent.addChild(childToken);
					walkSharpExpr(childToken);
				case POpen:
					walkPOpen(parent);
					return;
				default:
					parent.addChild(stream.consumeToken());
					return;
			}
		}
	}

	public static inline var SINGLELINE_IF1:String = "
		package xxxx;
	import blah.fasel;
	@autobuild
	class Test {
		/**
		* blah kfdjkjgfg jdk jgdfkjf
		* gfdiglkdfjgkdjfgkdfjg
		*/
		@SuppressWarnings('checkstyle:xxxx')
		public static inline function test(childs:Array<Dynamic>) {
			if (true) { return; } else { return; }
			for (child in childs) { trace(child).lah(); }
			for (i in 0...10) { trace('xxx'); }
			while ((i > 10) && ((j < 100) || (j >1000))) { trace('xxx'); }
		}
		//public static inline function test2(childs:Array<Dynamic>) {
		//    if (true) { return; } else { return; }
		//    for (child in childs) { trace(child).lah(); }
		//    for (i in 0...10) { trace('xxx'); }
		//    while ((i > 10) && ((j < 100) || (j >1000))) { trace('xxx'); }
		//}
	}";

	public static inline var SINGLELINE_IF2:String = "
	class Test {

		// require comment in empty block / object decl
		//public static inline var TEXT:String = 'text';
		// empty block / object decl can be empty or have comments
		// if block has no comments, enforces {} notation
		//public static inline var EMPTY:String = 'empty';

		public function new(x:Array<Int>=[1,2,3,4]) {
			super();
#if js
			var xxx:test;
#else
#end
#if (php || neko)
#end
			@Test('hallo');
			var x='TokenStream';
			thresholds = [
				{ severity : 'WARNING', complexity : 20 },
				{ severity : 'ERROR', complexity : 25 }
			];
		}
	}";

	public static inline var SINGLELINE_IF:String = "
		function test(childs:Array<Dynamic>,text:String,?default:Float=10):Int {
			for (child in childs) { trace(child).lah(); }
			//for (i in 0...10) { trace('xxx'); }
			//while ((i > 10) && ((j < 100) || (j >1000))) { trace('xxx'); }
			//if (true) { return; } else { return;
			//    if (text == 'fdklfklgdk') return 1;
			//    else return 2;
			//}
			return text == 'xx' || default > 100 && default <10;
		}
	";

	public static function main() {

		//var code = File.getContent('checkstyle/TokenTreeBuilder.hx');
		//var code = File.getContent('checkstyle/checks/CyclomaticComplexityCheck.hx');
		//var code = File.getContent('checkstyle/checks/TypeNameCheck.hx');
		var code = SINGLELINE_IF2;
		var tokens:Array<Token> = [];
		var lexer = new HaxeLexer(byte.ByteData.ofString(code), "TokenStream");
		var t:Token = lexer.token(HaxeLexer.tok);

		while (t.tok != Eof) {
			tokens.push(t);
			t = lexer.token(haxeparser.HaxeLexer.tok);
		}

		var root:TokenTree = TokenTreeBuilder.buildTokenTree(tokens);
		trace (root);
		//trace (root.filter([Kwd(KwdImport), Kwd(KwdUsing)], All));
		//trace (root.filter([Const(CString("TokenStream"))], All));
		trace (root.filterConstString(All));
		//trace (root.filter([Kwd(KwdFunction)], FirstLevel));
		//trace (root.filter([Kwd(KwdIf)], All));
		//trace (root.filter([DblDot], All));
	}
}