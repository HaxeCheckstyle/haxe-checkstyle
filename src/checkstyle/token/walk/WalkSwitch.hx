package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkSwitch {
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
	public static function walkSwitch(stream:TokenStream, parent:TokenTree) {
		var switchTok:TokenTree = stream.consumeTokenDef(Kwd(KwdSwitch));
		parent.addChild(switchTok);
		WalkComment.walkComment(stream, switchTok);
		WalkStatement.walkStatement(stream, switchTok);
		WalkComment.walkComment(stream, switchTok);
		var brOpen:TokenTree = stream.consumeTokenDef(BrOpen);
		switchTok.addChild(brOpen);
		WalkSwitch.walkSwitchCases(stream, brOpen);
		brOpen.addChild(stream.consumeTokenDef(BrClose));
	}

	public static function walkSwitchCases(stream:TokenStream, parent:TokenTree) {
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case BrClose:
					break;
				case Kwd(KwdCase), Kwd(KwdDefault):
					WalkSwitch.walkCase(stream, parent);
				case Sharp(_):
					WalkSharp.walkSharp(stream, parent, WalkSwitch.walkSwitchCases);
				case Comment(_), CommentLine(_):
					WalkStatement.walkStatement(stream, parent);
				default:
					stream.error('bad token ${stream.token()} != case/default');
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
	static function walkCase(stream:TokenStream, parent:TokenTree) {
		WalkComment.walkComment(stream, parent);
		var caseTok:TokenTree = stream.consumeToken();
		parent.addChild(caseTok);
		WalkSwitch.walkCaseExpr(stream, caseTok);
		var dblDot:TokenTree = stream.consumeTokenDef(DblDot);
		caseTok.addChild(dblDot);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdCase), Kwd(KwdDefault), BrClose:
					return;
				case BrOpen:
					WalkBlock.walkBlock(stream, dblDot);
				default:
					WalkStatement.walkStatement(stream, dblDot);
			}
		}
	}

	static function walkCaseExpr(stream:TokenStream, parent:TokenTree) {
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case POpen:
					WalkPOpen.walkPOpen(stream, parent);
				case BrOpen:
					WalkObjectDecl.walkObjectDecl(stream, parent);
				case BkOpen:
					WalkArrayAccess.walkArrayAccess(stream, parent);
				case Kwd(KwdFunction):
					WalkFunction.walkFunction(stream, parent, []);
				case Kwd(KwdIf):
					WalkIf.walkIf(stream, parent);
				case Binop(OpGt):
					var child:TokenTree = stream.consumeOpGt();
					parent.addChild(child);
					WalkSwitch.walkCaseExpr(stream, child);
				case Binop(OpSub):
					var child:TokenTree = stream.consumeOpSub();
					parent.addChild(child);
					WalkSwitch.walkCaseExpr(stream, child);
				case Semicolon, BrClose, BkClose, PClose, DblDot:
					return;
				case Comment(_), CommentLine(_):
					var child:TokenTree = stream.consumeToken();
					parent.addChild(child);
				default:
					var child:TokenTree = stream.consumeToken();
					parent.addChild(child);
					WalkSwitch.walkCaseExpr(stream, child);
			}
		}
	}
}