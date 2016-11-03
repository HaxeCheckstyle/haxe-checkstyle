package checkstyle.checks.whitespace;

import Type.ValueType;
import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Expr.Binop;
import haxe.macro.Expr.Unop;

@name("Spacing")
@desc("Spacing check on if, for, while, switch, try statements and around operators.")
class SpacingCheck extends Check {

	public var spaceAroundBinop:Bool;
	public var noSpaceAroundUnop:Bool;
	public var spaceIfCondition:Directive;
	public var spaceForLoop:Directive;
	public var spaceWhileLoop:Directive;
	public var spaceSwitchCase:Bool;
	public var spaceCatch:Bool;
	public var ignoreRangeOperator:Bool;

	public function new() {
		super(AST);
		spaceAroundBinop = true;
		noSpaceAroundUnop = true;
		spaceIfCondition = SHOULD;
		spaceForLoop = SHOULD;
		spaceWhileLoop = SHOULD;
		spaceSwitchCase = true;
		spaceCatch = true;
		ignoreRangeOperator = true;
		categories = [Category.STYLE, Category.CLARITY];
	}

	override public function configureProperty(name:String, value:Any) {
		var currentValue = Reflect.field(this, name);

		switch (Type.typeof(currentValue)) {
			case ValueType.TClass(String):
				Reflect.setField(this, name, (value:Directive));
			case _:
				super.configureProperty(name, value);
		}
	}

	override function actualRun() {
		var lastExpr = null;

		ExprUtils.walkFile(checker.ast, function(e) {
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
				case EIf(econd, _, _):
					checkSpaceBetweenExpressions("if", e, econd, spaceIfCondition);
				case EFor(it, _):
					checkSpaceBetweenExpressions("for", e, it, spaceForLoop);
				case EWhile(econd, _, true):
					checkSpaceBetweenExpressions("while", e, econd, spaceWhileLoop);
				case ESwitch(eswitch, _, _) if (spaceSwitchCase):
					checkSpaceBetweenManually("switch", lastExpr, eswitch);
				case ETry(etry, catches) if (spaceCatch):
					var exprBeforeCatch = lastExpr;
					for (ctch in catches) {
						checkSpaceBetweenManually("catch", exprBeforeCatch, ctch.expr);
						exprBeforeCatch = ctch.expr;
					}
				default:
			}

			lastExpr = e;
		});
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

	function checkSpaceBetweenExpressions(name:String, e1:Expr, e2:Expr, directive:Directive = SHOULD) {
		switch (directive) {
			case ANY:
			case SHOULD_NOT:
				if (e2.pos.min - e1.pos.min > '$name('.length) {
					logRange('Space between "$name" and "("', e1.pos.max, e2.pos.min);
				}
			case SHOULD:
				if (e2.pos.min - e1.pos.min < '$name ('.length) {
					logRange('No space between "$name" and "("', e1.pos.max, e2.pos.min);
				}
		}
	}

	function checkSpaceBetweenManually(name:String, before:Expr, check:Expr) {
		var prevExprUntilChecked = checker.file.content.substring(before.pos.min, check.pos.min + 1);
		var checkPos = prevExprUntilChecked.lastIndexOf('$name(');
		if (checkPos > -1) {
			var fileCheckPos = before.pos.min + checkPos;
			logRange('No space between "$name" and "("', fileCheckPos, fileCheckPos + '$name('.length);
		}
	}
}