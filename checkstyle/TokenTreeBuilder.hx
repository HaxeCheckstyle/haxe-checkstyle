package checkstyle;

import sys.io.File;

import haxe.macro.Expr;

import haxeparser.HaxeLexer;

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
		trace (root);
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
				case BrClose: break;
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		//block.addChild(stream.consumeTokenDef(BrClose));
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
		if (stream.is(Binop(OpEq))) {
			walkTokens(name, Semicolon);
		}
		name.addChild(stream.consumeTokenDef(Semicolon));
	}

	function walkMethod(parent:TokenTree, prefixes:Array<TokenTree>) {
		var funcTok:TokenTree = stream.consumeTokenDef(Kwd(KwdFunction));
		var name:TokenTree;
		parent.addChild(funcTok);
		if (stream.is(Kwd(KwdNew))) name = stream.consumeToken();
		else name = stream.consumeConstIdent();
		trace (name);
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
	}

	function walkInterface(parent:TokenTree) {
	}

	function walkAbstract(parent:TokenTree) {
	}

	function walkTypedef(parent:TokenTree) {
	}

	function walkEnum(parent:TokenTree) {
	}

	function walkStatement(parent:TokenTree) {
		var newChild:TokenTree = null;
		//if (stream.is(PClose)) return;
		if (stream.is(POpen)) walkPOpen(parent);
		if (stream.is(BrOpen)) return walkBlock(parent);
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
			case BkOpen:
				walkTokens(newChild, BkClose);
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
					return walkTokens(newChild, BrClose);
				case BkOpen:
					return walkTokens(newChild, BkClose);
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
					return walkBlock(newChild);
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
			parent.addChild(openTok);
			trace (openTok);
			while (true) {
				if (stream.is(BrClose)) break;
				trace ('line: ${stream.token()}');
				walkStatement(openTok);
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else walkStatement(parent);
	}

	function walkCaseBlock(parent:TokenTree) {
		//var newChild:TokenTree = null;
		while(true) {
			switch (stream.token()) {
				case Kwd(KwdCase): return;
				case Kwd(KwdDefault): return;
				case BrClose: return;

				default: walkStatement(parent);
				//case Comment(_), CommentLine(_):
				//    newChild = stream.consumeToken();
				//    parent.addChild(newChild);
				//case Kwd(KwdCase): return;
				//// TODO: Semicolon is not sufficient for switch/cases -> blocks are implicit
				//default: return walkTokens(parent, Semicolon);
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
		walkTokens(parent);
	}

	function walkPOpen(parent:TokenTree) {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		while (true) {
			if (stream.is(PClose)) break;
			walkStatement(pOpen);
		}
		pOpen.addChild(stream.consumeTokenDef(PClose));
		//var newChild:TokenTree = null;
		//if (!stream.is(POpen)) return;
		//newChild = stream.consumeToken();
		//parent.addChild(newChild);
		//walkTokens(newChild, PClose);
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
			//if (true) { return; } else { return; }
			//for (child in childs) { trace(child).lah(); }
			//for (i in 0...10) { trace('xxx'); }
			//while ((i > 10) && ((j < 100) || (j >1000))) { trace('xxx'); }
		}
		//public static inline function test2(childs:Array<Dynamic>) {
		//    if (true) { return; } else { return; }
		//    for (child in childs) { trace(child).lah(); }
		//    for (i in 0...10) { trace('xxx'); }
		//    while ((i > 10) && ((j < 100) || (j >1000))) { trace('xxx'); }
		//}
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
		var code = SINGLELINE_IF1;
		var tokens:Array<Token> = [];
		var lexer = new HaxeLexer(byte.ByteData.ofString(code), "TokenStream");
		var t:Token = lexer.token(HaxeLexer.tok);

		while (t.tok != Eof) {
			tokens.push(t);
			t = lexer.token(haxeparser.HaxeLexer.tok);
		}

		//var tokens:Array<Token> = [];
		//var pos:Position = {file:"file", min:0, max:1};

		//tokens.push(new Token(Kwd(KwdIf), pos));
		//tokens.push(new Token(POpen, pos));
		//tokens.push(new Token(Kwd(KwdTrue), pos));
		//tokens.push(new Token(PClose, pos));
		//tokens.push(new Token(BrOpen, pos));
		//tokens.push(new Token(Kwd(KwdReturn), pos));
		//tokens.push(new Token(Semicolon, pos));
		//tokens.push(new Token(BrClose, pos));
		//tokens.push(new Token(Kwd(KwdElse), pos));
		//tokens.push(new Token(BrOpen, pos));
		//tokens.push(new Token(Kwd(KwdReturn), pos));
		//tokens.push(new Token(Semicolon, pos));
		//tokens.push(new Token(Kwd(KwdIf), pos));
		//tokens.push(new Token(POpen, pos));
		//tokens.push(new Token(Const(CIdent('text')), pos));
		//tokens.push(new Token(Binop(OpEq), pos));
		//tokens.push(new Token(Const(CString('fdklfklgdk')), pos));
		//tokens.push(new Token(PClose, pos));
		//tokens.push(new Token(Kwd(KwdReturn), pos));
		//tokens.push(new Token(Const(CInt('1')), pos));
		//tokens.push(new Token(Semicolon, pos));
		//tokens.push(new Token(Kwd(KwdElse), pos));
		//tokens.push(new Token(Kwd(KwdReturn), pos));
		//tokens.push(new Token(Const(CInt('2')), pos));
		//tokens.push(new Token(Semicolon, pos));
		//tokens.push(new Token(BrClose, pos));

		var root:TokenTree = TokenTreeBuilder.buildTokenTree(tokens);
		//trace (root.filter([Kwd(KwdFunction)], All));
		//trace (root.filter([Kwd(KwdIf)], All));
		//trace (root.filter([DblDot], All));
	}
}