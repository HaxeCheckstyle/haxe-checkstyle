package checkstyle.token.walk;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenStreamProgress;
import checkstyle.token.TokenTree;

class WalkSharp {
	static var SHARP_IFS:Array<TokenTree> = [];

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
	public static function walkSharp(stream:TokenStream, parent:TokenTree, walker:WalkCB) {
		switch (stream.token()) {
			case Sharp(IF):
				WalkSharp.walkSharpIf(stream, parent, walker);
			case Sharp(ERROR):
				var errorToken:TokenTree = stream.consumeToken();
				parent.addChild(errorToken);
				switch (stream.token()) {
					case Const(CString(_)):
						errorToken.addChild(stream.consumeToken());
					default:
				}
			case Sharp(ELSEIF):
				WalkSharp.walkSharpElseIf(stream, parent);
			case Sharp(ELSE):
				WalkSharp.walkSharpElse(stream, parent);
			case Sharp(END):
				WalkSharp.walkSharpEnd(stream, parent);
			case Sharp(_):
				parent.addChild(stream.consumeToken());
			default:
		}
	}

	static function walkSharpIf(stream:TokenStream, parent:TokenTree, walker:WalkCB) {
		var ifToken:TokenTree = stream.consumeToken();
		parent.addChild(ifToken);
		WalkSharp.walkSharpIfExpr(stream, ifToken);
		SHARP_IFS.push(ifToken);

		var progress:TokenStreamProgress = new TokenStreamProgress(stream);
		while (progress.streamHasChanged()) {
			try {
				walker(stream, ifToken);
				switch (stream.token()) {
					case BrClose, Comma:
						var newChild:TokenTree = stream.consumeToken();
						ifToken.addChild(newChild);
					default:
				}
			}
			catch (e:SharpElseException) {
				// continue;
			}
			catch (e:SharpEndException) {
				SHARP_IFS.pop();
				if (!stream.hasMore()) return;
				switch (stream.token()) {
					case Comma:
						var newChild:TokenTree = stream.consumeToken();
						ifToken.addChild(newChild);
					default:
				}
				return;
			}
		}
	}

	static function walkSharpElse(stream:TokenStream, parent:TokenTree) {
		var sharpIfParent:TokenTree = SHARP_IFS[SHARP_IFS.length - 1];
		var ifToken:TokenTree = stream.consumeToken();
		sharpIfParent.addChild(ifToken);
		throw new SharpElseException();
	}

	static function walkSharpElseIf(stream:TokenStream, parent:TokenTree) {
		var sharpIfParent:TokenTree = SHARP_IFS[SHARP_IFS.length - 1];
		var ifToken:TokenTree = stream.consumeToken();
		sharpIfParent.addChild(ifToken);
		WalkSharp.walkSharpIfExpr(stream, ifToken);
		throw new SharpElseException();
	}

	static function walkSharpEnd(stream:TokenStream, parent:TokenTree) {
		var sharpIfParent:TokenTree = SHARP_IFS[SHARP_IFS.length - 1];
		var endToken:TokenTree = stream.consumeToken();
		sharpIfParent.addChild(endToken);
		throw new SharpEndException();
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
}

typedef WalkCB = TokenStream -> TokenTree -> Void;

class SharpElseException {
	public function new () {}
}

class SharpEndException {
	public function new () {}
}

@:enum
abstract WalkSharpConsts(String) to String {
	var IF = "if";
	var ELSEIF = "elseif";
	var ELSE = "else";
	var END = "end";
	var ERROR = "error";
}