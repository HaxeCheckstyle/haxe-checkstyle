package checkstyle.token;

import haxe.macro.Expr;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

class TokenTree extends Token {

	static inline var MAX_LEVEL:Int = 9999;

	public var parent:TokenTree;
	public var previousSibling:TokenTree;
	public var childs:Array<TokenTree>;

	public function new(tok:TokenDef, pos:Position) {
		super(tok, pos);
	}

	public function is(tokenDef:TokenDef):Bool {
		if (tok == null) return false;
		return Type.enumEq(tokenDef, tok);
	}

	public function addChild(child:TokenTree) {
		if (childs == null) childs = [];
		if (childs.length > 0) child.previousSibling = childs[childs.length - 1];
		childs.push (child);
		child.parent = this;
	}

	public function hasChilds():Bool {
		if (childs == null) return false;
		return childs.length > 0;
	}

	public function getFirstChild():TokenTree {
		if (!hasChilds()) return null;
		return childs[0];
	}

	public function getLastChild():TokenTree {
		if (!hasChilds()) return null;
		return childs[childs.length - 1];
	}

	public function getPos():Position {
		if ((childs == null) || (childs.length <= 0)) return pos;

		var fullPos:Position = {file:pos.file, min:pos.min, max:pos.max};
		var childPos:Position;
		for (child in childs) {
			childPos = child.getPos();
			if (childPos.min < pos.min) fullPos.min = childPos.min;
			if (childPos.max > pos.max) fullPos.max = childPos.max;
		}
		return fullPos;
	}

	public function filter(searchFor:Array<TokenDef>, mode:TokenFilterMode, maxLevel:Int = MAX_LEVEL):Array<TokenTree> {
		return filterCallback(function(token:TokenTree):Bool {
				return token.matchesAny(searchFor);
			},
			mode, maxLevel);
	}

	public function filterCallback(callback:FilterCallback, mode:TokenFilterMode, maxLevel:Int = MAX_LEVEL):Array<TokenTree> {
		var results:Array<TokenTree> = [];

		if (maxLevel < 0) return [];
		if (callback(this)) {
			if (mode == ALL) {
				results.push (this);
			}
			else {
				return [this];
			}
		}
		if (childs == null) return results;
		for (child in childs) {
			switch (child.tok) {
				case Sharp(_):
					results = results.concat(child.filterCallback(callback, mode, maxLevel));
				default:
					results = results.concat(child.filterCallback(callback, mode, maxLevel - 1));
			}
		}
		return results;
	}

	function matchesAny(searchFor:Array<TokenDef>):Bool {
		if (searchFor == null) return false;
		if (tok == null) return false;
		for (search in searchFor) {
			if (Type.enumEq(tok, search)) {
				return true;
			}
		}
		return false;
	}

	override public function toString():String {
		return printTokenTree();
	}

	public function printTokenTree(prefix:String = ""):String {
		var buf:StringBuf = new StringBuf();
		if (tok != null) buf.add('$prefix${tok}\t\t\t\t${getPos()}');
		if (childs == null) return buf.toString();
		for (child in childs) {
			buf.add('\n$prefix${child.printTokenTree(prefix + "  ")}');
		}
		return buf.toString();
	}
}

@SuppressWarnings('checkstyle:MemberName')
enum TokenFilterMode {
	ALL;
	FIRST;
}

typedef FilterCallback = TokenTree -> Bool;