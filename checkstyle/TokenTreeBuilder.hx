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
		tokenizer.walkFile(root);
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
					tempStore.push(walkAt());
				case Kwd(KwdClass), Kwd(KwdInterface), Kwd(KwdEnum), Kwd(KwdTypedef), Kwd(KwdAbstract):
					walkType(parent, tempStore);
					tempStore = [];
				default:
					tempStore.push(stream.consumeToken());
			}
		}
	}
	function walkType(parent:TokenTree, prefixes:Array<TokenTree>) {
		var newChild:TokenTree = stream.consumeToken();
		// add keyword (class, interface, abstract, typedef, enum)
		parent.addChild(newChild);
		parent = newChild;
		// add name
		var name:TokenTree = walkTypeNameDef(parent);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		switch (parent.tok) {
			case Kwd(KwdClass):
				walkClass(name);
			case Kwd(KwdInterface):
				walkInterface(name);
			case Kwd(KwdAbstract):
				walkAbstract(name);
			case Kwd(KwdTypedef):
				walkTypedef(name);
			case Kwd(KwdEnum):
				walkEnum(name);
			default:
		}
	}

	function walkClass(parent:TokenTree) {
		var newChild:TokenTree;
		walkExtends(parent);
		walkImplements(parent);
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		parent.addChild(block);

		while (stream.hasMore()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					walkVar(block, tempStore);
					tempStore = [];
				case Kwd(KwdFunction):
					walkFunction(block, tempStore);
					tempStore = [];
				case At:
					tempStore.push(walkAt());
				case BrClose: break;
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		block.addChild(stream.consumeTokenDef(BrClose));
	}

	function walkAt():TokenTree {
		var atTok:TokenTree = stream.consumeTokenDef(At);
		var parent:TokenTree = atTok;
		if (stream.is(DblDot)) {
			var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
			atTok.addChild(dblDot);
			parent = dblDot;
		}
		var name:TokenTree = stream.consumeConstIdent();
		parent.addChild(name);
		if (stream.is(POpen)) walkPOpen(name);
		return atTok;
	}

	function walkInterface(parent:TokenTree) {
		var newChild:TokenTree;

		walkExtends(parent);

		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		parent.addChild(block);
		while (stream.hasMore()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					walkVar(block, tempStore);
					tempStore = [];
				case Kwd(KwdFunction):
					walkFunction(block, tempStore);
					tempStore = [];
				case At:
					tempStore.push(walkAt());
				case BrClose: break;
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		block.addChild(stream.consumeTokenDef(BrClose));
	}

	function walkAbstract(parent:TokenTree) {
		if (stream.is(POpen)) walkPOpen(parent);
		var typeParent:TokenTree = parent;
		var typeChild:TokenTree;
		while(true) {
			switch (stream.token()) {
				case BrOpen: break;
				default:
					typeChild = stream.consumeToken();
					typeParent.addChild(typeChild);
					typeParent = typeChild;
			}
		}
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		parent.addChild(block);

		while (stream.hasMore()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					walkVar(block, tempStore);
					tempStore = [];
				case Kwd(KwdFunction):
					walkFunction(block, tempStore);
					tempStore = [];
				case At:
					tempStore.push(walkAt());
				case BrClose: break;
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		block.addChild(stream.consumeTokenDef(BrClose));
	}

	function walkTypedef(parent:TokenTree) {
		var assign:TokenTree = stream.consumeTokenDef(Binop(OpAssign));
		parent.addChild(assign);
		walkBlock(assign);
	}

	function walkEnum(parent:TokenTree) {
		walkBlock(parent);
	}

	function walkExtends(parent:TokenTree) {
		if (!stream.is(Kwd(KwdExtends))) return;
		var parentType:TokenTree = stream.consumeTokenDef(Kwd(KwdExtends));
		parent.addChild(parentType);
		walkTypeNameDef(parentType);
		walkExtends(parentType);
	}

	function walkImplements(parent:TokenTree) {
		if (!stream.is(Kwd(KwdImplements))) return;
		var interfacePart:TokenTree = stream.consumeTokenDef(Kwd(KwdImplements));
		parent.addChild(interfacePart);
		walkTypeNameDef(interfacePart);
		walkImplements(interfacePart);
	}

	function walkVar(parent:TokenTree, prefixes:Array<TokenTree>) {
		var name:TokenTree;
		var varTok:TokenTree = stream.consumeTokenDef(Kwd(KwdVar));
		parent.addChild(varTok);
		name = stream.consumeConstIdent();
		varTok.addChild(name);
		for (stored in prefixes) name.addChild(stored);
		if (stream.is(DblDot)) {
			var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
			name.addChild(dblDot);
			walkTypeNameDef(dblDot);
		}
		if (stream.is(Binop(OpAssign))) {
			walkStatement(name);
			return;
		}
		name.addChild(stream.consumeTokenDef(Semicolon));
	}

	function walkFunction(parent:TokenTree, prefixes:Array<TokenTree>) {
		var funcTok:TokenTree = stream.consumeTokenDef(Kwd(KwdFunction));
		parent.addChild(funcTok);

		var name:TokenTree = funcTok;
		switch (stream.token()) {
			case Kwd(KwdNew):
				name = stream.consumeToken();
				funcTok.addChild(name);
			case POpen:
			default:
				name = walkTypeNameDef(funcTok);
		}
		for (stored in prefixes) name.addChild(stored);
		walkPOpen(name);
		if (stream.is(DblDot)) {
			var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
			name.addChild(dblDot);
			walkTypeNameDef(name);
		}
		walkBlock(name);
	}

	function walkTypeNameDef(parent:TokenTree):TokenTree {
		var name:TokenTree;
		name = stream.consumeConst();
		parent.addChild(name);
		if (stream.is(Binop(OpLt))) walkLtGt(name);
		if (stream.is(Arrow)) {
			var arrow:TokenTree = stream.consumeTokenDef(Arrow);
			name.addChild (arrow);
			walkTypeNameDef(name);
		}
		return name;
	}

	function walkLtGt(parent:TokenTree) {
		var ltTok:TokenTree = stream.consumeTokenDef(Binop(OpLt));
		while(true) {
			switch (stream.token()) {
				case Comma:
					var comma:TokenTree = stream.consumeTokenDef(Comma);
					ltTok.addChild (comma);
					walkTypeNameDef(ltTok);
				case Binop(OpGt): break;
				case DblDot:
					var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
					ltTok.addChild(dblDot);
					walkTypeNameDef(ltTok);
				default:
					walkTypeNameDef(ltTok);
			}
		}
		ltTok.addChild(stream.consumeTokenDef(Binop(OpGt)));
	}

	function walkStatement(parent:TokenTree) {
		var newChild:TokenTree = null;
		switch (stream.token()) {
			case POpen:
				walkPOpen(parent);
				return;
			case BrOpen:
				walkObjectDecl(parent);
				return;
			case BkOpen:
				walkArrayAccess(parent);
				return;
			case BrClose, BkClose, PClose:
				return;
			case Sharp(_):
				walkSharp(parent);
				return;
			case Kwd(KwdFunction):
				walkFunction(newChild, []);
				return;
			default:
		}
		newChild = stream.consumeToken();
		parent.addChild(newChild);
		switch (newChild.tok) {
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
			case Kwd(KwdTry):
				walkTry(newChild);
			case Kwd(KwdCatch):
				walkCatch(newChild);
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
			while (true) {
				if (stream.is(BrClose)) break;
				walkStatement(openTok);
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else walkStatement(parent);
	}

	function walkObjectDecl(parent:TokenTree) {
		var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
		parent.addChild(openTok);
		while (true) {
			if (stream.is(BrClose)) break;
			if (stream.is(Comma)) {
				openTok.addChild(stream.consumeToken());
				continue;
			}
			if (stream.is(DblDot)) {
				openTok.addChild(stream.consumeToken());
			}
			walkStatement(openTok);
		}
		openTok.addChild(stream.consumeTokenDef(BrClose));
	}

	function walkPOpen(parent:TokenTree) {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		parent.addChild(pOpen);
		while (true) {
			if (stream.is(POpen)) {
				walkPOpen(pOpen);
				continue;
			}
			if (stream.is(BrOpen)) {
				walkObjectDecl(pOpen);
				continue;
			}
			if (stream.is(BkOpen)) {
				walkArrayAccess(pOpen);
				continue;
			}
			if (stream.is(PClose)) break;
			pOpen.addChild(stream.consumeToken());
		}
		pOpen.addChild(stream.consumeTokenDef(PClose));
	}

	function walkArrayAccess(parent:TokenTree) {
		var bkOpen:TokenTree = stream.consumeTokenDef(BkOpen);
		parent.addChild(bkOpen);
		var tempStore:Array<TokenTree> = [];
		while (true) {
			switch(stream.token()) {
				case POpen:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					walkPOpen(bkOpen);
				case BrOpen:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					walkBlock(bkOpen);
				case BkOpen:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					walkArrayAccess(bkOpen);
				case BkClose:
					break;
				case At:
					tempStore.push(walkAt());
				case Kwd(KwdFunction):
					walkFunction(bkOpen, tempStore);
					tempStore = [];
				default:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					bkOpen.addChild(stream.consumeToken());
			}
		}
		bkOpen.addChild(stream.consumeTokenDef(BkClose));
	}

	function walkIf(parent:TokenTree) {
		// condition
		walkPOpen(parent);
		if (stream.is(DblDot)) return;
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
		walkCaseExpr(parent);
		var newChild:TokenTree = null;
		while(stream.hasMore()) {
			switch (stream.token()) {
				case Kwd(KwdCase), Kwd(KwdDefault), BrClose:
					return;
				case BrOpen:
					walkBlock(parent);
				default:
					walkStatement(parent);
			}
		}
	}

	function walkCaseExpr(parent:TokenTree) {
		var newChild:TokenTree = null;
		switch (stream.token()) {
			case POpen:
				walkPOpen(parent);
				return;
			case BrOpen:
				walkObjectDecl(parent);
				return;
			case BkOpen:
				walkArrayAccess(parent);
				return;
			case DblDot:
				return;
			case Kwd(KwdFunction):
				walkFunction(newChild, []);
				return;
			default:
		}
		newChild = stream.consumeToken();
		parent.addChild(newChild);
		switch (newChild.tok) {
			case Kwd(KwdIf):
				walkIf(newChild);
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

	function walkTry(parent:TokenTree) {
		walkBlock(parent);
	}

	function walkCatch(parent:TokenTree) {
		walkPOpen(parent);
		walkBlock(parent);
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

	public static inline var TOKENTREE_BUILDER_TEST:String = "
	class Test {
		public function log(msg:String, l:Int, c:Int, sev:SeverityLevel) {
			var x:Int = 0;
			x+=100;
			x*=100;
			x/=100;
			x|=100;
			x&=100;
			x>>=100;
			x<<=100;
			x>>>=100;
			messages.push({
				//fileName:checker.file.name,
				//message:msg,
				//line:l,
				//column:c,
				//severity:sev,
				moduleName:getModuleName()
			});
		}
	}";

	public static function main() {

		//var code = File.getContent('checkstyle/TokenTree.hx');
		var code = File.getContent('checkstyle/Checker.hx');
		//var code = File.getContent('checkstyle/checks/CyclomaticComplexityCheck.hx');
		//var code = File.getContent('checkstyle/checks/TypeNameCheck.hx');
		// var code = File.getContent('checkstyle/checks/RightCurlyCheck.hx');
		//var code = TOKENTREE_BUILDER_TEST;
		var tokens:Array<Token> = [];
		var lexer = new HaxeLexer(byte.ByteData.ofString(code), "TokenStream");
		var t:Token = lexer.token(HaxeLexer.tok);

		while (t.tok != Eof) {
			tokens.push(t);
			t = lexer.token(haxeparser.HaxeLexer.tok);
		}

		var root:TokenTree = TokenTreeBuilder.buildTokenTree(tokens);
		trace (root);
		//trace (root.filter([Kwd(KwdEnum)], ALL));
		//trace (root.filter([Kwd(KwdTypedef)], ALL));
		//trace (root.filter([Kwd(KwdAbstract)], ALL));
	}
}