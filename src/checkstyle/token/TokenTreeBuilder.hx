package checkstyle.token;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

class TokenTreeBuilder {

	var stream:TokenStream;

	function new(stream:TokenStream) {
		this.stream = stream;
	}

	public static function buildTokenTree(tokens:Array<Token>):TokenTree {
		var tokenizer:TokenTreeBuilder = new TokenTreeBuilder(new TokenStream(tokens));
		var root:TokenTree = new TokenTree(null, null, -1);
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
				case Sharp(_):
					walkSharp(parent);
				case At:
					tempStore.push(walkAt());
				case Comment(_), CommentLine(_):
					tempStore.push(stream.consumeToken());
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
		var name:TokenTree;
		switch (stream.token()) {
			case Const(_):
				name = stream.consumeConstIdent();
			default:
				name = stream.consumeToken();
		}
		parent.addChild(name);
		if (stream.is(POpen)) walkPOpen(name);
		return atTok;
	}

	function walkClass(parent:TokenTree, prefixes:Array<TokenTree>) {
		var typeTok:TokenTree = stream.consumeToken();
		parent.addChild(typeTok);
		walkComment(parent);
		var name:TokenTree = walkTypeNameDef(typeTok);
		// add all comments, annotations
		for (prefix in prefixes) name.addChild(prefix);
		if (stream.isSharp()) walkSharp(name);
		walkExtends(name);
		walkImplements(name);
		walkComment(name);
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);

		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					walkVar(block, tempStore);
					tempStore = [];
				case Kwd(KwdFunction):
					walkFunction(block, tempStore);
					tempStore = [];
				case Sharp(_):
					walkSharp(block);
				case At:
					tempStore.push(walkAt());
				case BrClose: break;
				case Semicolon:
					block.addChild(stream.consumeToken());
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		for (tok in tempStore) block.addChild(tok);
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
		walkImplements(name);
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					walkVar(block, tempStore);
					tempStore = [];
				case Kwd(KwdFunction):
					walkFunction(block, tempStore);
					tempStore = [];
				case Sharp(_):
					walkSharp(block);
				case At:
					tempStore.push(walkAt());
				case BrClose: break;
				case Semicolon:
					block.addChild(stream.consumeToken());
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		for (tok in tempStore) block.addChild(tok);
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
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case BrOpen: break;
				case Const(CIdent("from")), Const(CIdent("to")):
					var fromToken:TokenTree = stream.consumeToken();
					name.addChild(fromToken);
					walkTypeNameDef(fromToken);
				default:
					typeChild = stream.consumeToken();
					typeParent.addChild(typeChild);
					typeParent = typeChild;
			}
		}
		var tempStore:Array<TokenTree> = [];
		var block:TokenTree = stream.consumeTokenDef(BrOpen);
		name.addChild(block);

		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdVar):
					walkVar(block, tempStore);
					tempStore = [];
				case Kwd(KwdFunction):
					walkFunction(block, tempStore);
					tempStore = [];
				case Sharp(_):
					walkSharp(block);
				case At:
					tempStore.push(walkAt());
				case BrClose: break;
				case Semicolon:
					block.addChild(stream.consumeToken());
				default:
					tempStore.push(stream.consumeToken());
			}
		}
		for (tok in tempStore) block.addChild(tok);
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
		walkTypedefBody(assign);
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
		walkComment(parent);
		walkTypeNameDef(parentType);
		walkComment(parent);
		walkExtends(parentType);
		walkComment(parent);
	}

	function walkImplements(parent:TokenTree) {
		if (!stream.is(Kwd(KwdImplements))) return;
		var interfacePart:TokenTree = stream.consumeTokenDef(Kwd(KwdImplements));
		parent.addChild(interfacePart);
		walkComment(parent);
		walkTypeNameDef(interfacePart);
		walkComment(parent);
		walkImplements(interfacePart);
		walkComment(parent);
	}

	function walkVar(parent:TokenTree, prefixes:Array<TokenTree>) {
		var name:TokenTree = null;
		var varTok:TokenTree = stream.consumeTokenDef(Kwd(KwdVar));
		parent.addChild(varTok);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			name = stream.consumeConstIdent();
			varTok.addChild(name);
			if (stream.is(POpen)) {
				walkPOpen(name);
			}
			for (stored in prefixes) name.addChild(stored);
			if (stream.is(DblDot)) {
				var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
				name.addChild(dblDot);
				walkTypeNameDef(dblDot);
			}
			if (stream.is(Binop(OpAssign))) {
				walkStatement(name);
				if (stream.is(Semicolon)) {
					name.addChild(stream.consumeTokenDef(Semicolon));
				}
				return;
			}
			if (stream.is(Comma)) {
				var comma:TokenTree = stream.consumeTokenDef(Comma);
				name.addChild(comma);
				continue;
			}
			break;
		}
		name.addChild(stream.consumeTokenDef(Semicolon));
	}

	function walkNew(parent:TokenTree) {
		var newTok:TokenTree = stream.consumeTokenDef(Kwd(KwdNew));
		parent.addChild(newTok);
		var name:TokenTree = walkTypeNameDef(newTok);
		walkPOpen(name);
	}

	function walkFunction(parent:TokenTree, prefixes:Array<TokenTree>) {
		var funcTok:TokenTree = stream.consumeTokenDef(Kwd(KwdFunction));
		parent.addChild(funcTok);
		walkComment(funcTok);

		var name:TokenTree = funcTok;
		switch (stream.token()) {
			case Kwd(KwdNew):
				name = walkTypeNameDef(funcTok);
			case POpen:
			case Binop(OpLt):
				walkLtGt(funcTok);
				name = funcTok.getLastChild();
			default:
				name = walkTypeNameDef(funcTok);
		}
		for (stored in prefixes) name.addChild(stored);
		walkComment(name);
		walkFunctionParameters(name);
		walkComment(name);
		if (stream.is(DblDot)) {
			var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
			name.addChild(dblDot);
			walkTypeNameDef(dblDot);
		}
		walkBlock(name);
	}

	function walkFunctionParameters(parent:TokenTree) {
		var pOpen:TokenTree = stream.consumeTokenDef(POpen);
		parent.addChild(pOpen);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			if (stream.is(PClose)) break;
			walkFieldDef(pOpen);
		}
		pOpen.addChild(stream.consumeTokenDef(PClose));
	}

	function walkTypedefBody(parent:TokenTree) {
		if (stream.is(BrOpen)) {
			var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
			parent.addChild(openTok);
			var progress:TokenStreamProgress = new TokenStreamProgress(stream);
			while (progress.streamHasChanged()) {
				switch (stream.token()) {
					case BrClose: break;
					default:
						walkFieldDef(openTok);
				}
				if (stream.is(BrClose)) break;
				walkFieldDef(openTok);
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else walkTypeNameDef(parent);
	}

	function walkFieldDef(parent:TokenTree) {
		var tempStore:Array<TokenTree> = [];
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdVar), Kwd(KwdFunction):
					var tok:TokenTree = stream.consumeToken();
					parent.addChild(tok);
					parent = tok;
				case At:
					tempStore.push(walkAt());
				default:
					break;
			}
		}

		var name:TokenTree = walkTypeNameDef(parent);
		for (tok in tempStore) {
			name.addChild(tok);
		}

		if (stream.is(DblDot)) {
			var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
			name.addChild(dblDot);
			walkTypedefBody(dblDot);
		}
		if (stream.is(Binop(OpAssign))) {
			walkStatement(name);
		}
		switch (stream.token()) {
			case Comma:
				name.addChild(stream.consumeTokenDef(Comma));
			case Semicolon:
				name.addChild(stream.consumeTokenDef(Semicolon));
			default:
		}
	}

	function walkTypeNameDef(parent:TokenTree):TokenTree {
		if (stream.is(BrOpen)) {
			walkTypedefBody(parent);
			return parent.getFirstChild();
		}
		if (stream.is(Question)) {
			var questTok:TokenTree = stream.consumeTokenDef(Question);
			parent.addChild(questTok);
			parent = questTok;
		}
		var name:TokenTree;
		switch (stream.token()) {
			case Kwd(KwdMacro), Kwd(KwdExtern), Kwd(KwdNew):
				name = stream.consumeToken();
			case Const(_):
				name = stream.consumeConst();
			case Sharp(_):
				walkSharp(parent);
				return parent.getFirstChild();
			default:
				name = stream.consumeToken();
		}
		parent.addChild(name);
		if (stream.is(Dot)) {
			var dot:TokenTree = stream.consumeTokenDef(Dot);
			name.addChild(dot);
			walkTypeNameDef(dot);
			return name;
		}
		if (stream.is(Binop(OpLt))) walkLtGt(name);
		if (stream.is(Arrow)) {
			var arrow:TokenTree = stream.consumeTokenDef(Arrow);
			name.addChild(arrow);
			walkTypeNameDef(arrow);
		}
		return name;
	}

	function walkLtGt(parent:TokenTree) {
		var ltTok:TokenTree = stream.consumeTokenDef(Binop(OpLt));
		parent.addChild(ltTok);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Comma:
					var comma:TokenTree = stream.consumeTokenDef(Comma);
					ltTok.addChild(comma);
					walkTypeNameDef(ltTok);
					walkFieldDef(ltTok);
				case Binop(OpGt): break;
				case DblDot:
					var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
					ltTok.addChild(dblDot);
					walkTypeNameDef(ltTok);
				default:
					walkFieldDef(ltTok);
			}
		}
		ltTok.addChild(stream.consumeTokenDef(Binop(OpGt)));
	}

	function walkStatement(parent:TokenTree) {
		var wantMore:Bool = true;
		switch (stream.token()) {
			case Binop(OpSub):
				walkBinopSub(parent);
				return;
			case Binop(OpLt):
				if (stream.isTypedParam()) {
					walkLtGt(parent);
					return;
				}
				wantMore = true;
			case Binop(OpGt):
				var gtTok:TokenTree = stream.consumeOpGt();
				parent.addChild(gtTok);
				walkStatement(gtTok);
				return;
			case Binop(_):
				wantMore = true;
			case Unop(_):
				if (parent.tok.match(Const(_))) wantMore = false;
			case IntInterval(_):
				wantMore = true;
			case Kwd(_):
				if (walkKeyword(parent)) wantMore = true;
				else return;
			case BrOpen:
				walkObjectDecl(parent);
				return;
			case BkOpen:
				walkArrayAccess(parent);
				return;
			case Dollar(_):
				var dollarTok:TokenTree = stream.consumeToken();
				parent.addChild(dollarTok);
				walkBlock(dollarTok);
				return;
			case POpen:
				walkPOpen(parent);
				walkStatementContinue(parent);
				return;
			case Question:
				walkQuestion(parent);
				return;
			case PClose, BrClose, BkClose:
				return;
			case Comma:
				return;
			case Sharp(IF):
				walkSharp(parent);
				return;
			case Sharp(_):
				return;
			case Dot, DblDot:
				wantMore = true;
			default:
				wantMore = false;
		}
		var newChild:TokenTree = stream.consumeToken();
		parent.addChild(newChild);
		if (wantMore) walkStatement(newChild);
		walkStatementContinue(newChild);
	}

	function walkStatementContinue(parent:TokenTree) {
		switch (stream.token()) {
			case Dot:
				walkStatement(parent);
			case DblDot:
				var question:TokenTree = findQuestionParent(parent);
			    if (question != null) {
					walkStatement(question);
					return;
				}
				walkStatement(parent);
			case Binop(_), Unop(_):
				walkStatement(parent);
			case Question:
				walkStatement(parent);
			case Semicolon:
				walkStatement(parent);
			case BkOpen:
				walkStatement(parent);
			case POpen:
				walkStatement(parent);
			default:
		}
	}

	function walkKeyword(parent:TokenTree):Bool {
		switch (stream.token()) {
			case Kwd(KwdVar):
				walkVar(parent, []);
			case Kwd(KwdNew):
				walkNew(parent);
			case Kwd(KwdFor):
				walkFor(parent);
			case Kwd(KwdFunction):
				walkFunction(parent, []);
			case Kwd(KwdPackage), Kwd(KwdImport), Kwd(KwdUsing):
				walkPackageImport(parent);
			case Kwd(KwdExtends):
				walkExtends(parent);
			case Kwd(KwdImplements):
				walkImplements(parent);
			case Kwd(KwdClass):
				walkClass(parent, []);
			case Kwd(KwdMacro), Kwd(KwdReturn):
				return true;
			case Kwd(KwdSwitch):
				walkSwitch(parent);
			case Kwd(KwdIf):
				walkIf(parent);
			case Kwd(KwdTry):
				walkTry(parent);
			case Kwd(KwdDo):
				walkDoWhile(parent);
			case Kwd(KwdWhile):
				walkWhile(parent);
			default:
				return true;
		}
		return false;
	}

	function findQuestionParent(token:TokenTree):TokenTree {
		var parent:TokenTree = token;
		while (parent.tok != null) {
			switch (parent.tok) {
				case Question: return parent;
				case Comma: return null;
				case POpen, BrOpen, BkOpen: return null;
				case Kwd(_): return null;
				default:
			}
			parent = parent.parent;
		}
		return null;
	}

	function walkBinopSub(parent:TokenTree) {
		var sub:TokenTree = stream.consumeOpSub();
		parent.addChild(sub);
		switch (sub.tok) {
			case Const(_):
				walkStatementContinue(sub);
			default:
				walkStatement(sub);
		}
	}

	function walkQuestion(parent:TokenTree) {
		var question:TokenTree = stream.consumeTokenDef(Question);
		parent.addChild(question);
		walkStatement(question);
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
			if (isArrayComprehension(parent)) {
				walkObjectDecl(parent);
				return;
			}
			var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
			parent.addChild(openTok);
			var progress:TokenStreamProgress = new TokenStreamProgress(stream);
			while (progress.streamHasChanged()) {
				if (stream.is(BrClose)) break;
				walkStatement(openTok);
			}
			openTok.addChild(stream.consumeTokenDef(BrClose));
		}
		else walkStatement(parent);
	}

	function isArrayComprehension(token:TokenTree):Bool {
		if ((token == null) || (token.tok == null)) return false;
		return switch (token.tok) {
			case BkOpen: true;
			case Kwd(KwdTypedef): true;
			case Kwd(KwdReturn): true;
			default: isArrayComprehension(token.parent);
		}
	}

	function walkObjectDecl(parent:TokenTree) {
		var openTok:TokenTree = stream.consumeTokenDef(BrOpen);
		parent.addChild(openTok);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
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
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case POpen:
					walkPOpen(pOpen);
				case BrOpen:
					walkObjectDecl(pOpen);
				case BkOpen:
					walkArrayAccess(pOpen);
				case PClose:
					break;
				case Sharp(_):
					walkSharp(pOpen);
				case Comma:
					var comma:TokenTree = stream.consumeToken();
					pOpen.addChild(comma);
				default:
					walkStatement(pOpen);
			}
		}
		pOpen.addChild(stream.consumeTokenDef(PClose));
	}

	function walkArrayAccess(parent:TokenTree) {
		var bkOpen:TokenTree = stream.consumeTokenDef(BkOpen);
		parent.addChild(bkOpen);
		var tempStore:Array<TokenTree> = [];
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdFor):
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					walkFor(bkOpen);
				case Kwd(KwdWhile):
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					walkWhile(bkOpen);
				case POpen:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					walkPOpen(bkOpen);
				case BrOpen:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					walkObjectDecl(bkOpen);
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
				case Comma:
					var comma:TokenTree = stream.consumeTokenDef(Comma);
					bkOpen.addChild(comma);
				default:
					for (stored in tempStore) bkOpen.addChild(stored);
					tempStore = [];
					walkStatement(bkOpen);
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
		walkComment(switchTok);
		walkStatement(switchTok);
		walkComment(switchTok);
		var brOpen:TokenTree = stream.consumeTokenDef(BrOpen);
		switchTok.addChild(brOpen);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case BrClose:
					break;
				case Kwd(KwdCase), Kwd(KwdDefault):
					walkCase(brOpen);
				case Sharp(_):
					walkSharp(brOpen);
				case Comment(_), CommentLine(_):
					walkStatement(brOpen);
				default:
					throw 'bad token ${stream.token()} != case/default';
			}
		}
		brOpen.addChild(stream.consumeTokenDef(BrClose));
	}

	function walkComment(parent:TokenTree) {
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Comment(_), CommentLine(_):
					var comment:TokenTree = stream.consumeToken();
					parent.addChild(comment);
				default:
					return;
			}
		}
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
		walkComment(parent);
		var caseTok:TokenTree = stream.consumeToken();
		parent.addChild(caseTok);
		walkCaseExpr(caseTok);
		var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
		caseTok.addChild(dblDot);
		var newChild:TokenTree = null;
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
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
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
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
				case Binop(OpGt):
					var child:TokenTree = stream.consumeOpGt();
					parent.addChild(child);
					walkCaseExpr(child);
				case Binop(OpSub):
					var child:TokenTree = stream.consumeOpSub();
					parent.addChild(child);
					walkCaseExpr(child);
				case Semicolon, BrClose, BkClose, PClose, DblDot:
					return;
				case Comment(_), CommentLine(_):
					var child:TokenTree = stream.consumeToken();
					parent.addChild(child);
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
		walkComment(catchTok);
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
		walkComment(whileTok);
		walkPOpen(whileTok);
		walkComment(whileTok);
		walkBlock(whileTok);
	}

	/**
	 * Kwd(KwdDo)
	 *  |- BrOpen
	 *  |   |- statement
	 *  |   |- statement
	 *  |   |- BrClose
	 *  |- Kwd(KwdWhile)
	 *      |- POpen
	 *      |   |- expression
	 *      |   |- PClose
	 *      |- Semicolon
	 *
	 */
	function walkDoWhile(parent:TokenTree) {
		var doTok:TokenTree = stream.consumeTokenDef(Kwd(KwdDo));
		parent.addChild(doTok);
		walkComment(doTok);
		walkBlock(doTok);
		var whileTok:TokenTree = stream.consumeTokenDef(Kwd(KwdWhile));
		doTok.addChild(whileTok);
		walkPOpen(whileTok);
		walkComment(whileTok);
		if (stream.is(Semicolon)) whileTok.addChild(stream.consumeToken());
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
		walkComment(forTok);
		walkForPOpen(forTok);
		walkComment(forTok);
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
		var identifier:TokenTree = stream.consumeConstIdent();
		parent.addChild(pOpen);
		pOpen.addChild(identifier);
		var inTok:TokenTree = stream.consumeTokenDef(Kwd(KwdIn));
		identifier.addChild(inTok);
		walkStatement(inTok);
		pOpen.addChild(stream.consumeTokenDef(PClose));
		walkComment(parent);
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
			case Sharp(IF):
				walkSharpIf(parent);
			case Sharp(ERROR):
				var errorToken:TokenTree = stream.consumeToken();
				parent.addChild(errorToken);
				switch (stream.token()) {
					case Const(CString(_)):
						errorToken.addChild(stream.consumeToken());
					default:
				}
			case Sharp(ELSEIF), Sharp(ELSE), Sharp(END):
				throw 'unexpected token ${stream.token()}';
			case Sharp(_):
				parent.addChild(stream.consumeToken());
			default:
		}
	}

	function walkSharpIf(parent:TokenTree) {
		var ifToken:TokenTree = stream.consumeToken();
		parent.addChild(ifToken);
		walkSharpIfExpr(ifToken);
		walkSharpExpr(ifToken);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Sharp(IF):
					walkSharp(ifToken);
				case Sharp(ELSEIF):
					walkSharpElseIf(ifToken);
				case Sharp(ELSE):
					var elseToken:TokenTree = stream.consumeToken();
					ifToken.addChild(elseToken);
					walkSharpExpr(elseToken);
					break;
				case Sharp(END):
					break;
				default:
					walkStatement(ifToken);
			}
		}
		ifToken.addChild(stream.consumeTokenDef(Sharp("end")));
	}

	function walkSharpElseIf(parent:TokenTree) {
		var ifToken:TokenTree = stream.consumeToken();
		parent.addChild(ifToken);
		walkSharpIfExpr(ifToken);
		walkSharpExpr(ifToken);
		if (stream.token().match(Sharp(_))) return;
		throw 'bad token ${stream.token()} != #elseif/#end';
	}

	function walkSharpIfExpr(parent:TokenTree) {
		var childToken:TokenTree;
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Unop(OpNot):
					childToken = stream.consumeToken();
					parent.addChild(childToken);
					walkSharpIfExpr(childToken);
					return;
				case POpen:
					walkPOpen(parent);
					return;
				case Kwd(_), Const(CIdent(_)):
					childToken = stream.consumeToken();
					parent.addChild(childToken);
					return;
				default:
					return;
			}
		}
	}

	function walkSharpExpr(parent:TokenTree) {
		var prefixes:Array<TokenTree> = [];
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdClass):
					walkClass(parent, prefixes);
					prefixes = [];
				case Kwd(KwdInterface):
					walkInterface(parent, prefixes);
					prefixes = [];
				case Kwd(KwdAbstract):
					walkAbstract(parent, prefixes);
					prefixes = [];
				case Kwd(KwdTypedef):
					walkTypedef(parent, prefixes);
					prefixes = [];
				case Kwd(KwdEnum):
					walkEnum(parent, prefixes);
					prefixes = [];
				case BrOpen:
					walkBlock(parent);
				case Sharp(IF), Sharp(ERROR):
					walkSharp(parent);
					return;
				case Sharp(_):
					return;
				case At:
					prefixes.push(walkAt());
				case Comment(_), CommentLine(_):
					prefixes.push(stream.consumeToken());
				default:
					walkStatement(parent);
			}
		}
	}
}

@:enum
abstract TokenTreeBuilderSharpConsts(String) to String {
	var IF = "if";
	var ELSEIF = "elseif";
	var ELSE = "else";
	var END = "end";
	var ERROR = "error";
}