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
		switch (stream.token()) {
			case Kwd(KwdClass):
				walkClass(parent, prefixes);
			case Kwd(KwdInterface):
				walkInterface(parent, prefixes);
			case Kwd(KwdAbstract):
				walkAbstract(parent, prefixes);
			case Kwd(KwdTypedef):
				walkTypedef(parent, prefixes);
			case Kwd(KwdEnum):
				walkEnum(parent, prefixes);
			default:
		}
	}

	/**
	 * At
	 *  |- DblDot
	 *      |- Const(CIdent)
	 *          |- POpen
	 *              |- expression
	 *              |- PClose
	 *
	 * At
	 *  |- DblDot
	 *      |- Const(CIdent)
	 *
	 * At
	 *  |- Const(CIdent)
	 *      |- POpen
	 *          |- expression
	 *          |- PClose
	 *
	 * At
	 *  |- Const(CIdent)
	 *
	 */
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

	function walkClass(parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		var name:TokenTree = walkTypeNameDef(typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		walkExtends(name);
		walkImplements(name);
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);

		while (true) {
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

	function walkInterface(parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		// add name
		var name:TokenTree = walkTypeNameDef(typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		walkExtends(name);
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);
		while (true) {
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

	function walkAbstract(parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		var name:TokenTree = walkTypeNameDef(typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		if (stream.is(POpen)) walkPOpen(name);
		var typeParent:TokenTree = name;
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
		name.addChild(block);

		while (true) {
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

	function walkTypedef(parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		var name:TokenTree = walkTypeNameDef(typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		var assign:TokenTree = stream.consumeTokenDef(Binop(OpAssign));
		name.addChild(assign);
		walkBlock(assign);
	}

	function walkEnum(parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		var name:TokenTree = walkTypeNameDef(typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		walkBlock(name);
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
			case BrOpen:
				walkObjectDecl(parent);
			case BkOpen:
				walkArrayAccess(parent);
			case Sharp(_):
				walkSharp(parent);
			case Kwd(KwdFunction):
				walkFunction(parent, []);
			case Kwd(KwdIf):
				walkIf(parent);
			case Kwd(KwdTry):
				walkTry(parent);
			case Kwd(KwdFor):
				walkFor(parent);
			case Kwd(KwdWhile):
				walkWhile(parent);
			case Kwd(KwdSwitch):
				walkSwitch(parent);
			case Binop(OpGt):
				newChild = stream.consumeOpGt();
				parent.addChild(newChild);
				walkStatement(newChild);
			case Binop(OpSub):
				newChild = stream.consumeOpSub();
				parent.addChild(newChild);
				walkStatement(newChild);
			case BrClose, BkClose, PClose:
			default:
				newChild = stream.consumeToken();
				parent.addChild(newChild);
				switch (newChild.tok) {
					case Comment(_), CommentLine(_), Comma, Semicolon:
					default:
						walkStatement(newChild);
				}
		}
	}

	/**
	 * Kwd(KwdPackage)
	 *  |- Const(CIdent(_))
	 *      |- Dot
	 *          |- Const(CIdent(_))
	 *              |- Semicolon
	 *
	 * Kwd(KwdImport)
	 *  |- Const(CIdent(_))
	 *      |- Dot
	 *          |- Const(CIdent(_))
	 *              |- Semicolon
	 *
	 */
	function walkPackageImport(parent:TokenTree) {
		var newChild:TokenTree = null;
		newChild = stream.consumeToken();
		parent.addChild(newChild);
		if (Type.enumEq(Semicolon, newChild.tok)) return;
		walkPackageImport(newChild);
	}

	/**
	 * BrOpen
	 *  |- statement
	 *  |- startement
	 *  |- BrClose
	 *
	 */
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
			walkStatement(pOpen);
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
					walkStatement(bkOpen);
					//bkOpen.addChild(stream.consumeToken());
			}
		}
		bkOpen.addChild(stream.consumeTokenDef(BkClose));
	}

	/**
	 * Kwd(KwdIf)
	 *  |- POpen
	 *  |   |- expression
	 *  |   |- PClose
	 *  |- BrOpen
	 *  |   |- statement
	 *  |   |- statement
	 *  |   |- BrClose
	 *  |- Kwd(KwdElse)
	 *      |- BrOpen
	 *          |- statement
	 *          |- statement
	 *          |- BrClose
	 *
	 */
	function walkIf(parent:TokenTree) {
		var ifTok:TokenTree = stream.consumeTokenDef(Kwd(KwdIf));
		parent.addChild(ifTok);
		// condition
		walkPOpen(ifTok);
		if (stream.is(DblDot)) return;
		// if-expr
		walkBlock(ifTok);
		if (stream.is(Kwd(KwdElse))) {
			var elseTok:TokenTree = stream.consumeTokenDef(Kwd(KwdElse));
			ifTok.addChild(elseTok);
			// else-expr
			walkBlock(elseTok);
		}
	}

	/**
	 * Kwd(KwdSwitch)
	 *  |- POpen
	 *  |   |- expression
	 *  |   |- PClose
	 *  |- BrOpen
	 *      |- Kwd(KwdCase)
	 *      |   |- expression
	 *      |   |- DblDot
	 *      |       |- statement
	 *      |       |- statement
	 *      |- Kwd(KwdCase)
	 *      |   |- expression
	 *      |   |- DblDot
	 *      |       |- BrOpen
	 *      |           |- statement
	 *      |           |- BrClose
	 *      |- Kwd(KwdDefault)
	 *      |- BrClose
	 *
	 */
	function walkSwitch(parent:TokenTree) {
		var switchTok:TokenTree = stream.consumeTokenDef(Kwd(KwdSwitch));
		parent.addChild(switchTok);
		walkPOpen(switchTok);
		var brOpen:TokenTree = stream.consumeTokenDef(BrOpen);
		switchTok.addChild(brOpen);
		while (true) {
			switch (stream.token()) {
				case BrClose:
					break;
				case Kwd(KwdCase), Kwd(KwdDefault):
					walkCase(brOpen);
				default:
					walkStatement(switchTok);
			}
		}

		brOpen.addChild(stream.consumeTokenDef(BrClose));
	}

	/**
	 * Kwd(KwdCase) | Kwd(KwdDefault)
	 *  |- expression
	 *  |- DblDot
	 *      |- statement
	 *      |- statement
	 *
	 * Kwd(KwdCase) | Kwd(KwdDefault)
	 *  |- expression
	 *  |- DblDot
	 *      |- BrOpen
	 *          |- statement
	 *          |- BrClose
	 *
	 */
	function walkCase(parent:TokenTree) {
		if (!stream.is(Kwd(KwdCase)) && !stream.is(Kwd(KwdDefault))) {
			throw 'bad token ${stream.token()} != case/default';
		}
		var caseTok:TokenTree = stream.consumeToken();
		parent.addChild(caseTok);
		walkCaseExpr(caseTok);
		var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
		caseTok.addChild(dblDot);
		var newChild:TokenTree = null;
		while(true) {
			switch (stream.token()) {
				case Kwd(KwdCase), Kwd(KwdDefault), BrClose:
					return;
				case BrOpen:
					walkBlock(dblDot);
				default:
					walkStatement(dblDot);
			}
		}
	}

	function walkCaseExpr(parent:TokenTree) {
		while (true) {
			switch (stream.token()) {
				case POpen:
					walkPOpen(parent);
				case BrOpen:
					walkObjectDecl(parent);
				case BkOpen:
					walkArrayAccess(parent);
				case Kwd(KwdFunction):
					walkFunction(parent, []);
				case Kwd(KwdIf):
					walkIf(parent);
				case Kwd(KwdFor):
					walkFor(parent);
				case Kwd(KwdWhile):
					walkWhile(parent);
				case Binop(OpGt):
					var child:TokenTree = stream.consumeOpGt();
					parent.addChild(child);
					walkCaseExpr(child);
				case Binop(OpSub):
					var child:TokenTree = stream.consumeOpSub();
					parent.addChild(child);
					walkCaseExpr(child);
				case Comment(_), CommentLine(_), Semicolon, BrClose, BkClose, PClose, DblDot:
					return;
				default:
					var child:TokenTree = stream.consumeToken();
					parent.addChild(child);
					walkCaseExpr(child);
			}
		}
	}

	/**
	 * Kwd(KwdTry)
	 *  |- BrOpen
	 *  |   |- statement
	 *  |   |- statement
	 *  |   |- BrClose
	 *  |- Kwd(KwdCatch)
	 *  |   |- BrOpen
	 *  |       |- statement
	 *  |       |- statement
	 *  |       |- BrClose
	 *  |- Kwd(KwdCatch)
	 *      |- BrOpen
	 *          |- statement
	 *          |- statement
	 *          |- BrClose
	 *
	 */
	function walkTry(parent:TokenTree) {
		var tryTok:TokenTree = stream.consumeTokenDef(Kwd(KwdTry));
		parent.addChild(tryTok);
		walkBlock(tryTok);
		while (stream.is(Kwd(KwdCatch))) {
			walkCatch(tryTok);
		}
	}

	/**
	 * Kwd(KwdCatch)
	 *  |- BrOpen
	 *      |- statement
	 *      |- statement
	 *      |- BrClose
	 *
	 */
	function walkCatch(parent:TokenTree) {
		var catchTok:TokenTree = stream.consumeTokenDef(Kwd(KwdCatch));
		parent.addChild(catchTok);
		walkPOpen(catchTok);
		walkBlock(catchTok);
	}

	/**
	 * Kwd(KwdWhile)
	 *  |- POpen
	 *  |   |- expression
	 *  |   |- PClose
	 *  |- BrOpen
	 *      |- statement
	 *      |- statement
	 *      |- BrClose
	 *
	 */
	function walkWhile(parent:TokenTree) {
		var whileTok:TokenTree = stream.consumeTokenDef(Kwd(KwdWhile));
		parent.addChild(whileTok);
		walkPOpen(whileTok);
		walkBlock(whileTok);
	}

	/**
	 * Kwd(KwdFor)
	 *  |- POpen
	 *  |   |- Const(CIdent(_))
	 *  |   |   |- Kwd(KwdIn)
	 *  |   |       |- Const(CIdent(_)
	 *  |   |- PClose
	 *  |- BrOpen
	 *      |- statement
	 *      |- statement
	 *      |- BrClose
	 *
	 * Kwd(KwdFor)
	 *  |- POpen
	 *  |   |- Const(CIdent(_))
	 *  |   |   |- Kwd(KwdIn)
	 *  |   |       |- IntInterval(_)
	 *  |   |           |- Const(CInt(_))
	 *  |   |- PClose
	 *  |- BrOpen
	 *      |- statement
	 *      |- statement
	 *      |- BrClose
	 *
	 */
	function walkFor(parent:TokenTree) {
		var forTok:TokenTree = stream.consumeTokenDef(Kwd(KwdFor));
		parent.addChild(forTok);
		walkForPOpen(forTok);
		walkBlock(forTok);
	}

	/**
	 * POpen
	 *  |- Const(CIdent(_))
	 *  |   |- Kwd(KwdIn)
	 *  |       |- Const(CIdent(_)
	 *  |- PClose
	 *
	 * POpen
	 *  |- Const(CIdent(_))
	 *  |   |- Kwd(KwdIn)
	 *  |       |- IntInterval(_)
	 *  |           |- Const(CInt(_))
	 *  |- PClose
	 *
	 */
	function walkForPOpen(parent:TokenTree) {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		var iterator:TokenTree = stream.consumeConstIdent();
		if (!stream.is(Kwd(KwdIn))) {
			stream.rewind();
			stream.rewind();
			walkPOpen(parent);
			return;
		}
		parent.addChild(pOpen);
		pOpen.addChild(iterator);
		var inTok:TokenTree = stream.consumeTokenDef(Kwd(KwdIn));
		iterator.addChild(inTok);
		while (true) {
			if (stream.is(PClose)) break;
			walkStatement(inTok);
		}
		pOpen.addChild(stream.consumeTokenDef(PClose));
		return;
	}

	/**
	 * Sharp("if") | Sharp("elseif")
	 *  |- POpen
	 *      |- expression
	 *      |- PClose
	 *
	 * Sharp("if") | Sharp("elseif")
	 *  |- expression
	 *
	 * Sharp("end")
	 *
	 * Sharp("else")
	 *
	 * Sharp(_)
	 *
	 */
	function walkSharp(parent:TokenTree) {
		switch (stream.token()) {
			case Sharp("if"), Sharp("elseif"):
				var ifToken:TokenTree = stream.consumeToken();
				parent.addChild(ifToken);
				walkSharpExpr(ifToken);
			case Sharp("else"), Sharp("end"):
				parent.addChild(stream.consumeToken());
			case Sharp(_): // TODO handle other #directives
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
}