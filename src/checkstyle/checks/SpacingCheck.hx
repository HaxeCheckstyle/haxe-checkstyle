package checkstyle.checks;

import haxe.macro.Expr;
import haxe.macro.Printer;
import haxe.macro.Expr.Binop;
import haxe.macro.Expr.Unop;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("Spacing")
@desc("Spacing check on if statement and around operators")
class SpacingCheck extends Check {

	public var spaceAroundBinop:Bool;
	public var noSpaceAroundUnop:Bool;
	public var spaceIfCondition:Bool;
	public var spaceForLoop:Bool;
	public var spaceWhileLoop:Bool;
	public var spaceSwitchCase:Bool;
	public var ignoreRangeOperator:Bool;

	public function new() {
		super();
		spaceAroundBinop = true;
		noSpaceAroundUnop = true;
		spaceIfCondition = true;
		spaceForLoop = true;
		spaceWhileLoop = true;
		spaceSwitchCase = true;
		ignoreRangeOperator = true;
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
					if (r.pos.min - l.pos.max < binopSize(bo) + 2) logPos('No space around ${binopString(bo)}', e.pos, Reflect.field(SeverityLevel, severity));
				case EUnop(uo, post, e2) if (noSpaceAroundUnop):
					var dist = 0;
					if (post) dist = e.pos.max - e2.pos.max;
					else dist = e2.pos.min - e.pos.min;
					if (dist > unopSize(uo)) logPos('Space around ${unopString(uo)}', e.pos, Reflect.field(SeverityLevel, severity));
				case EIf(econd, _, _) if (spaceIfCondition):
					checkSpaceBetweenExpressions('if', e, econd);
				case EFor(it, _) if (spaceForLoop):
					checkSpaceBetweenExpressions('for', e, it);
				case EWhile(econd, _, true) if (spaceWhileLoop):
					checkSpaceBetweenExpressions('while', e, econd);
				case ESwitch(eswitch, _, _) if (spaceSwitchCase):
					var prevExprUntilSwitch = checker.file.content.substring(lastExpr.pos.min, eswitch.pos.min + 1);
					var switchPos = prevExprUntilSwitch.lastIndexOf('switch(');
					if (switchPos > -1) {
						var fileSwitchPos = lastExpr.pos.min + switchPos;
						logRange('No space between switch and (', fileSwitchPos, fileSwitchPos + 'switch('.length, Reflect.field(SeverityLevel, severity));
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

	function checkSpaceBetweenExpressions(name:String, e1:Expr, e2:Expr) {
		if (e2.pos.min - e1.pos.min < '$name ('.length) {
			logRange('No space between $name and (', e1.pos.min, e2.pos.min, Reflect.field(SeverityLevel, severity));
		}
	}
}