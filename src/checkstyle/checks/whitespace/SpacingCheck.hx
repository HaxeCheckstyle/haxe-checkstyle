package checkstyle.checks.whitespace;

import haxe.macro.Printer;
import Type.ValueType;
import checkstyle.checks.Directive;

@name("Spacing")
@desc("Spacing check on if, for, while, switch, try statements and around operators.")
class SpacingCheck extends Check {

	public var spaceAroundBinop:Bool;
	public var noSpaceAroundUnop:Bool;
	public var spaceIfCondition:Directive;
	public var spaceForLoop:Directive;
	public var spaceWhileLoop:Directive;
	public var spaceSwitchCase:Directive;
	public var spaceCatch:Directive;
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

	override public function configureProperty(name:String, value:Any) {
		var currentValue = Reflect.field(this, name);
		switch (Type.typeof(currentValue)) {
			case ValueType.TEnum(Directive):
				Reflect.setField(this, name, DirectiveTools.fromAny(value));
			case _:
				super.configureProperty(name, value);
		}
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var acceptableTokens:Array<TokenTree> = root.filter([
			Kwd(KwdIf),
			Kwd(KwdFor),
			Kwd(KwdWhile),
			Kwd(KwdSwitch),
			Kwd(KwdCatch)
		], ALL);

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

	function checkSpaceBetweenExpressions(name:String, e1:TokenTree, e2:TokenTree, directive:Directive) {
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
}