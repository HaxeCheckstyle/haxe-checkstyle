package checkstyle.checks.whitespace;

import haxe.macro.Printer;

/**
	Spacing check on if, for, while, switch, try statements and around operators.
**/
@name("Spacing")
@desc("Spacing check on if, for, while, switch, try statements and around operators.")
class SpacingCheck extends Check {
	/**
		require space around Binop operators ("+", "-", "/", etc.)
	**/
	public var spaceAroundBinop:Bool;

	/**
		enforce no space around Unop operators ("++", "--", "!", "-", "~")
	**/
	public var noSpaceAroundUnop:Bool;

	/**
		policy for if statements (space between "if" and "(")
		- should = require space between statement and condition
		- shouldNot = no space should between statement and condition
		- any = ignored by space check
	**/
	public var spaceIfCondition:SpacingPolicy;

	/**
		policy for for statements (space between "for" and "(")
		- should = require space between statement and condition
		- shouldNot = no space should between statement and condition
		- any = ignored by space check
	**/
	public var spaceForLoop:SpacingPolicy;

	/**
		policy for while statements (space between while" and "(")
		- should = require space between statement and condition
		- shouldNot = no space should between statement and condition
		- any = ignored by space check
	**/
	public var spaceWhileLoop:SpacingPolicy;

	/**
		policy for switch statements (space between "switch" and "(")
		- should = require space between statement and condition
		- shouldNot = no space should between statement and condition
		- any = ignored by space check
	**/
	public var spaceSwitchCase:SpacingPolicy;

	/**
		policy for catch statements (space between "catch" and "(")
		- should = require space between statement and condition
		- shouldNot = no space should between statement and condition
		- any = ignored by space check
	**/
	public var spaceCatch:SpacingPolicy;

	/**
		exclude range operator "..." from "spaceAroundBinop"
	**/
	public var ignoreRangeOperator:Bool;

	public function new() {
		super(TOKEN);
		spaceIfCondition = SHOULD;
		spaceForLoop = SHOULD;
		spaceWhileLoop = SHOULD;
		spaceSwitchCase = SHOULD;
		spaceCatch = SHOULD;
		spaceAroundBinop = true;
		noSpaceAroundUnop = true;
		ignoreRangeOperator = true;
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, depth:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdIf), Kwd(KwdFor), Kwd(KwdWhile), Kwd(KwdSwitch), Kwd(KwdCatch):
					FoundGoDeeper;
				default:
					GoDeeper;
			}
		});

		for (token in acceptableTokens) {
			var firstChild:TokenTree = token.getFirstChild();
			switch (token.tok) {
				case Kwd(KwdIf):
					checkSpaceBetweenExpressions(token.toString(), token, firstChild, spaceIfCondition);
				case Kwd(KwdFor):
					checkSpaceBetweenExpressions(token.toString(), token, firstChild, spaceForLoop);
				case Kwd(KwdWhile):
					checkSpaceBetweenExpressions(token.toString(), token, firstChild, spaceWhileLoop);
				case Kwd(KwdSwitch):
					checkSpaceBetweenExpressions(token.toString(), token, firstChild, spaceSwitchCase);
				case Kwd(KwdCatch):
					checkSpaceBetweenExpressions(token.toString(), token, firstChild, spaceCatch);
				case _:
			}
		}

		var lastExpr = null;

		if (checker.ast == null) return;
		checker.ast.walkFile(function(e) {
			if (lastExpr == null) {
				lastExpr = e;
				return;
			}

			switch (e.expr) {
				case EBinop(bo, l, r) if (spaceAroundBinop):
					if (ignoreRangeOperator && binopString(bo) == "...") return;
					if (r.pos.min - l.pos.max < binopSize(bo) + 2) logPos('No space around "${binopString(bo)}"', e.pos);
				case EUnop(uo, post, e2) if (noSpaceAroundUnop):
					var dist = 0;
					if (post) dist = e.pos.max - e2.pos.max;
					else dist = e2.pos.min - e.pos.min;
					if (dist > unopSize(uo)) logPos('Space around "${unopString(uo)}"', e.pos);
				default:
			}

			lastExpr = e;
		});
	}

	function checkSpaceBetweenExpressions(name:String, e1:TokenTree, e2:TokenTree, directive:SpacingPolicy) {
		if (e2 == null) return;
		switch (directive) {
			case ANY:
			case SHOULD_NOT:
				if (e2.pos.max - e1.pos.max > 1) logRange('Space between "$name" and "("', e2.pos.max, e2.pos.min);
			case SHOULD:
				if (e2.pos.max - e1.pos.max == 1) logRange('No space between "$name" and "("', e1.pos.max, e2.pos.min);
		}
	}

	function binopSize(bo:Binop):Int {
		return binopString(bo).length;
	}

	function binopString(bo:Binop):String {
		return (new Printer()).printBinop(bo);
	}

	function unopSize(uo:Unop):Int {
		return unopString(uo).length;
	}

	function unopString(uo:Unop):String {
		return (new Printer()).printUnop(uo);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "spaceIfCondition",
				values: [SHOULD, SHOULD_NOT, ANY]
			}, {
				propertyName: "spaceForLoop",
				values: [SHOULD, SHOULD_NOT, ANY]
			}, {
				propertyName: "spaceWhileLoop",
				values: [SHOULD, SHOULD_NOT, ANY]
			}, {
				propertyName: "spaceWhileLoop",
				values: [SHOULD, SHOULD_NOT, ANY]
			}, {
				propertyName: "spaceSwitchCase",
				values: [SHOULD, SHOULD_NOT, ANY]
			}, {
				propertyName: "spaceCatch",
				values: [SHOULD, SHOULD_NOT, ANY]
			}, {
				propertyName: "ignoreRangeOperator",
				values: [true, false]
			}, {
				propertyName: "spaceAroundBinop",
				values: [true, false]
			}, {
				propertyName: "noSpaceAroundUnop",
				values: [true, false]
			}]
		}];
	}
}

/**
	- should = require space between statement and condition
	- shouldNot = no space should between statement and condition
	- any = ignored by space check
**/
enum abstract SpacingPolicy(String) {
	var SHOULD = "should";
	var SHOULD_NOT = "should_not";
	var ANY = "any";
}