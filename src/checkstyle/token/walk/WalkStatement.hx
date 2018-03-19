package checkstyle.token.walk;

class WalkStatement {
	public static function walkStatement(stream:TokenStream, parent:TokenTree) {
		WalkComment.walkComment(stream, parent);

		var tempStore:Array<TokenTree> = [];
		var wantMore:Bool = true;
		switch (stream.token()) {
			case At:
				tempStore.push(WalkAt.walkAt(stream));
			case Binop(OpSub):
				WalkBinopSub.walkBinopSub(stream, parent);
				return;
			case Binop(OpLt):
				if (stream.isTypedParam()) {
					WalkLtGt.walkLtGt(stream, parent);
					return;
				}
				wantMore = true;
			case Binop(OpGt):
				var gtTok:TokenTree = stream.consumeOpGt();
				parent.addChild(gtTok);
				WalkStatement.walkStatement(stream, gtTok);
				return;
			case Binop(_):
				wantMore = true;
			case Unop(_):
				if (parent.tok.match(Const(_))) wantMore = false;
			case IntInterval(_):
				wantMore = true;
			case Kwd(_):
				if (WalkStatement.walkKeyword(stream, parent)) wantMore = true;
				else return;
			case Arrow:
				wantMore = true;
			case BrOpen:
				WalkObjectDecl.walkObjectDecl(stream, parent);
				return;
			case BkOpen:
				WalkArrayAccess.walkArrayAccess(stream, parent);
				WalkStatement.walkStatementContinue(stream, parent);
				return;
			case Dollar(_):
				var dollarTok:TokenTree = stream.consumeToken();
				parent.addChild(dollarTok);
				WalkBlock.walkBlock(stream, dollarTok);
				return;
			case POpen:
				var pOpen:TokenTree = WalkPOpen.walkPOpen(stream, parent);
				WalkStatement.walkStatementContinue(stream, pOpen);
				return;
			case Question:
				WalkQuestion.walkQuestion(stream, parent);
				return;
			case PClose, BrClose, BkClose:
				return;
			case Comma:
				return;
			case Sharp(_):
				WalkSharp.walkSharp(stream, parent, WalkStatement.walkStatement);
				return;
			case Dot, DblDot:
				wantMore = true;
			default:
				wantMore = false;
		}
		var newChild:TokenTree = stream.consumeToken();
		parent.addChild(newChild);
		for (tok in tempStore) newChild.addChild(tok);
		if (wantMore) WalkStatement.walkStatement(stream, newChild);
		WalkStatement.walkStatementContinue(stream, newChild);
	}

	public static function walkStatementContinue(stream:TokenStream, parent:TokenTree) {
		switch (stream.token()) {
			case Dot:
				WalkStatement.walkStatement(stream, parent);
			case DblDot:
				var question:TokenTree = findQuestionParent(parent);
				if (question != null) {
					WalkStatement.walkStatement(stream, question);
					return;
				}
				var dblDotTok:TokenTree = stream.consumeToken();
				parent.addChild(dblDotTok);
				WalkTypeNameDef.walkTypeNameDef(stream, dblDotTok);
				if (stream.is(Arrow)) {
					WalkStatement.walkStatement(stream, parent);
				}
			case Arrow:
				WalkStatement.walkStatement(stream, parent);
			case Binop(_), Unop(_):
				WalkStatement.walkStatement(stream, parent);
			case Question:
				WalkStatement.walkStatement(stream, parent);
			case Semicolon:
				WalkStatement.walkStatement(stream, parent);
			case BkOpen:
				WalkStatement.walkStatement(stream, parent);
			case POpen:
				WalkStatement.walkStatement(stream, parent);
			default:
		}
	}

	static function walkKeyword(stream:TokenStream, parent:TokenTree):Bool {
		switch (stream.token()) {
			case Kwd(KwdVar):
				WalkVar.walkVar(stream, parent, []);
			case Kwd(KwdNew):
				if (parent.is(Dot)) {
					var newChild:TokenTree = stream.consumeToken();
					parent.addChild(newChild);
					WalkStatement.walkStatementContinue(stream, newChild);
				}
				else {
					WalkNew.walkNew(stream, parent);
				}
			case Kwd(KwdFor):
				WalkFor.walkFor(stream, parent);
			case Kwd(KwdFunction):
				WalkFunction.walkFunction(stream, parent, []);
			case Kwd(KwdPackage), Kwd(KwdImport), Kwd(KwdUsing):
				WalkPackageImport.walkPackageImport(stream, parent);
			case Kwd(KwdExtends):
				WalkExtends.walkExtends(stream, parent);
			case Kwd(KwdImplements):
				WalkImplements.walkImplements(stream, parent);
			case Kwd(KwdClass):
				WalkClass.walkClass(stream, parent, []);
			case Kwd(KwdMacro), Kwd(KwdReturn):
				return true;
			case Kwd(KwdSwitch):
				WalkSwitch.walkSwitch(stream, parent);
			case Kwd(KwdIf):
				WalkIf.walkIf(stream, parent);
			case Kwd(KwdTry):
				WalkTry.walkTry(stream, parent);
			case Kwd(KwdDo):
				WalkDoWhile.walkDoWhile(stream, parent);
			case Kwd(KwdWhile):
				WalkWhile.walkWhile(stream, parent);
			default:
				return true;
		}
		return false;
	}

	static function findQuestionParent(token:TokenTree):TokenTree {
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
}