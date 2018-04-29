package token.verify;

import haxe.PosInfos;

import massive.munit.Assert;

import haxeparser.Data;

class VerifyTokenTreeList implements IVerifyTokenTree {

	var tokens:Array<IVerifyTokenTree>;

	public function new(tokens:Array<IVerifyTokenTree>) {
		Assert.isNotNull(tokens);
		this.tokens = tokens;
	}

	public function filter(tok:TokenDef, ?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) {
			var child:IVerifyTokenTree = token.filter(tok, pos);
			if (!child.isEmpty()) list.push(child);
		}
		return new VerifyTokenTreeList(list);
	}

	public function childs(?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) {
			var childList:VerifyTokenTreeList = cast token.childs(pos);
			for (i in 0...childList.tokens.length) {
				list.push(childList.tokens[i]);
			}
		}
		return new VerifyTokenTreeList(list);
	}

	public function first(?pos:PosInfos):IVerifyTokenTree {
		Assert.isTrue (tokens.length >= 1, pos);
		return tokens[0];
	}

	public function last(?pos:PosInfos):IVerifyTokenTree {
		Assert.isTrue (tokens.length >= 2, pos);
		return tokens[tokens.length - 1];
	}

	public function at(index:Int, ?pos:PosInfos):IVerifyTokenTree {
		Assert.isTrue (tokens.length > index, pos);
		return tokens[index];
	}

	public function count(num:Int, ?pos:PosInfos):IVerifyTokenTree {
		Assert.areEqual(num, tokens.length, pos);
		return this;
	}

	public function noChilds(?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.noChilds(pos));
		return new VerifyTokenTreeList(list);
	}

	public function oneChild(?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.oneChild());
		return new VerifyTokenTreeList(list);
	}

	public function childFirst(?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.childFirst(pos));
		return new VerifyTokenTreeList(list);
	}

	public function childLast(?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.childLast(pos));
		return new VerifyTokenTreeList(list);
	}

	public function childAt(index:Int, ?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.childAt(index, pos));
		return new VerifyTokenTreeList(list);
	}

	public function childCount(count:Int, ?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.childCount(count, pos));
		return new VerifyTokenTreeList(list);
	}

	public function childCountAtLeast(count:Int, ?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.childCountAtLeast(count, pos));
		return new VerifyTokenTreeList(list);
	}

	public function is(tok:TokenDef, ?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.is(tok, pos));
		return new VerifyTokenTreeList(list);
	}

	public function isComment(?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (token in tokens) list.push (token.isComment(pos));
		return new VerifyTokenTreeList(list);
	}

	public function isEmpty(?pos:PosInfos):Bool {
		return ((tokens == null) || (tokens.length <= 0));
	}
}
