package checkstyle;

import haxe.macro.Expr;

import haxeparser.Data.Token;
import haxeparser.Data.TokenDef;

class TokenTree extends Token {

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

	public function filter(searchFor:Array<TokenDef>, mode:TokenFilterMode):Array<TokenTree> {
		return filterCallback(function(token:TokenTree):Bool {
			return token.matchesAny(searchFor);
		}, mode);
	}

	public function filterConstString(mode:TokenFilterMode):Array<TokenTree> {
		return filterCallback(function(token:TokenTree):Bool {
			if (token.tok == null) return false;
			return switch (token.tok) {
				case Const(CString(_)): true;
				default: false;
			}
		}, mode);
	}

	function filterCallback(callback:FilterCallback, mode:TokenFilterMode):Array<TokenTree> {
		var results:Array<TokenTree> = [];

		if (callback(this)) {
			if (mode == All) {
				results.push (this);
			}
			else {
				return [this];
			}
		}
		if (childs == null) return results;
		for (child in childs) {
			results = results.concat(child.filterCallback(callback, mode));
		}
		return results;
	}

	function matchesAny(searchFor:Array<TokenDef>):Bool {
		if (searchFor == null) return false;
		if (tok == null) return false;
		var tokString:String = Std.string(tok);
		for (search in searchFor) {
			if (tokString == Std.string(search)) {
				return true;
			}
		}
		return false;
	}

	override public function toString():String {
		return printTokenTree();
	}

	public function printTree(prefix:String = ""):String {
		var buf:StringBuf = new StringBuf();
		if (tok != null) buf.add('$prefix${super.toString()} ${tok} ${getPos()}');
		if (childs == null) return buf.toString();
		for (child in childs) {
			buf.add('\n$prefix${child.printTree(prefix + "  ")}');// ${child.pos}');
		}
		return buf.toString();
	}

	public function printTokenTree(prefix:String = ""):String {
		var buf:StringBuf = new StringBuf();
		if (tok != null) buf.add('$prefix${tok}\t\t\t\t${getPos()}');
		if (childs == null) return buf.toString();
		for (child in childs) {
			buf.add('\n$prefix${child.printTokenTree(prefix + "  ")}');// ${child.pos}');
		}
		return buf.toString();
	}
}

enum TokenFilterMode {
	All;
	FirstLevel;
}

typedef FilterCallback = TokenTree -> Bool;