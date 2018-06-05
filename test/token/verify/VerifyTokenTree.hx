package token.verify;

import haxe.PosInfos;

import massive.munit.Assert;

import haxeparser.Data;

import checkstyle.token.TokenTree;

class VerifyTokenTree implements IVerifyTokenTree {

	var token:TokenTree;

	public function new(token:TokenTree) {
		Assert.isNotNull(token);
		this.token = token;
	}

	public function filter(tok:TokenDef, ?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (child in token.children) {
			if (child.is(tok)) list.push(new VerifyTokenTree(child));
		}
		return new VerifyTokenTreeList(list);
	}

	public function childs(?pos:PosInfos):IVerifyTokenTree {
		var list:Array<IVerifyTokenTree> = [];
		for (child in token.children) list.push(new VerifyTokenTree(child));
		return new VerifyTokenTreeList(list);
	}

	public function first(?pos:PosInfos):IVerifyTokenTree {
		return childFirst(pos);
	}

	public function last(?pos:PosInfos):IVerifyTokenTree {
		return childLast(pos);
	}

	public function at(index:Int, ?pos:PosInfos):IVerifyTokenTree {
		return childAt(index, pos);
	}

	public function count(num:Int, ?pos:PosInfos):IVerifyTokenTree {
		Assert.areEqual(num, 1, pos);
		return this;
	}

	public function noChilds(?pos:PosInfos):IVerifyTokenTree {
		if (token.children == null) return this;
		Assert.areEqual(0, token.children.length, pos);
		return this;
	}

	public function oneChild(?pos:PosInfos):IVerifyTokenTree {
		Assert.areEqual(1, token.children.length, pos);
		return this;
	}

	public function childFirst(?pos:PosInfos):IVerifyTokenTree {
		childCountAtLeast(1, pos);
		return new VerifyTokenTree(token.getFirstChild());
	}

	public function childLast(?pos:PosInfos):IVerifyTokenTree {
		childCountAtLeast(1, pos);
		return new VerifyTokenTree(token.getLastChild());
	}

	public function childAt(index:Int, ?pos:PosInfos):IVerifyTokenTree {
		childCountAtLeast(index + 1, pos);
		return new VerifyTokenTree(token.children[index]);
	}

	public function childCount(count:Int, ?pos:PosInfos):IVerifyTokenTree {
		if ((token.children == null) && (count != 0)) Assert.fail('${token.tok} has no childs', pos);
		Assert.areEqual(count, token.children.length, '[${token.tok}] child count [${token.children.length}] was not equal to expected [$count]', pos);
		return this;
	}

	public function childCountAtLeast(count:Int, ?pos:PosInfos):IVerifyTokenTree {
		if ((token.children == null) && (count != 0)) Assert.fail('${token.tok} has no childs', pos);
		Assert.isTrue(token.children.length >= count, pos);
		return this;
	}

	public function is(tok:TokenDef, ?pos:PosInfos):IVerifyTokenTree {
		Assert.isTrue(token.is(tok), '$tok != ${token.tok}', pos);
		return this;
	}

	public function isComment(?pos:PosInfos):IVerifyTokenTree {
		switch (token.tok) {
			case Comment(_), CommentLine(_): return this;
			default:
				Assert.fail('${token.tok} is not a comment', pos);
		}
		return this;
	}

	public function isEmpty(?pos:PosInfos):Bool {
		return token == null;
	}
}