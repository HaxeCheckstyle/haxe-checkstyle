package checkstyle.token.walk;

import haxe.macro.Expr;
import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkSharp {
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
	public static function walkSharp(stream:TokenStream, parent:TokenTree) {
		switch (stream.token()) {
			case Sharp(IF):
				WalkSharp.walkSharpIf(stream, parent);
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

	static function walkSharpIf(stream:TokenStream, parent:TokenTree) {
		var ifToken:TokenTree = stream.consumeToken();
		parent.addChild(ifToken);
		WalkSharp.walkSharpIfExpr(stream, ifToken);
		WalkSharp.walkSharpExpr(stream, ifToken);
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Sharp(IF):
					WalkSharp.walkSharp(stream, ifToken);
				case Sharp(ELSEIF):
					WalkSharp.walkSharpElseIf(stream, ifToken);
				case Sharp(ELSE):
					var elseToken:TokenTree = stream.consumeToken();
					ifToken.addChild(elseToken);
					WalkSharp.walkSharpExpr(stream, elseToken);
					break;
				case Sharp(END):
					break;
				case Comma:
					var comma:TokenTree = stream.consumeToken();
					ifToken.addChild(comma);
				default:
					WalkStatement.walkStatement(stream, ifToken);
			}
		}
		ifToken.addChild(stream.consumeTokenDef(Sharp("end")));
	}

	static function walkSharpElseIf(stream:TokenStream, parent:TokenTree) {
		var ifToken:TokenTree = stream.consumeToken();
		parent.addChild(ifToken);
		WalkSharp.walkSharpIfExpr(stream, ifToken);
		WalkSharp.walkSharpExpr(stream, ifToken);
		if (stream.token().match(Sharp(_))) return;
		stream.error('bad token ${stream.token()} != #elseif/#end');
	}

	static function walkSharpIfExpr(stream:TokenStream, parent:TokenTree) {
		var childToken:TokenTree;
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Unop(OpNot):
					childToken = stream.consumeToken();
					parent.addChild(childToken);
					WalkSharp.walkSharpIfExpr(stream, childToken);
					return;
				case POpen:
					WalkPOpen.walkPOpen(stream, parent);
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

	static function walkSharpExpr(stream:TokenStream, parent:TokenTree) {
		var prefixes:Array<TokenTree> = [];
		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			switch (stream.token()) {
				case Kwd(KwdClass):
					WalkClass.walkClass(stream, parent, prefixes);
					prefixes = [];
				case Kwd(KwdInterface):
					WalkInterface.walkInterface(stream, parent, prefixes);
					prefixes = [];
				case Kwd(KwdAbstract):
					WalkAbstract.walkAbstract(stream, parent, prefixes);
					prefixes = [];
				case Kwd(KwdTypedef):
					WalkTypedef.walkTypedef(stream, parent, prefixes);
					prefixes = [];
				case Kwd(KwdEnum):
					WalkEnum.walkEnum(stream, parent, prefixes);
					prefixes = [];
				case BrOpen:
					WalkBlock.walkBlock(stream, parent);
				case Sharp(IF), Sharp(ERROR):
					WalkSharp.walkSharp(stream, parent);
					return;
				case Sharp(_):
					return;
				case At:
					prefixes.push(WalkAt.walkAt(stream));
				case Comment(_), CommentLine(_):
					prefixes.push(stream.consumeToken());
				default:
					WalkStatement.walkStatement(stream, parent);
			}
		}
	}
}

@:enum
abstract WalkSharpConsts(String) to String {
	var IF = "if";
	var ELSEIF = "elseif";
	var ELSE = "else";
	var END = "end";
	var ERROR = "error";
}