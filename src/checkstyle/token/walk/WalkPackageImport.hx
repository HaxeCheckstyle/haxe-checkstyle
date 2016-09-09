package checkstyle.token.walk;

import haxeparser.Data.TokenDef;

import checkstyle.token.TokenStream;
import checkstyle.token.TokenTree;

class WalkPackageImport {
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

	public static function walkPackageImport(stream:TokenStream, parent:TokenTree) {
		var newChild:TokenTree = null;
		newChild = stream.consumeToken();
		parent.addChild(newChild);
		if (Type.enumEq(Semicolon, newChild.tok)) return;
		WalkPackageImport.walkPackageImport(stream, newChild);
	}
}