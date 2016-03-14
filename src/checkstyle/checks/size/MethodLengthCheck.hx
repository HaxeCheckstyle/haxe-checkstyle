package checkstyle.checks.size;

import checkstyle.utils.ExprUtils;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Function;

@name("MethodLength")
@desc("Checks for long methods (default 50 lines)")
class MethodLengthCheck extends Check {

	static var DEFAULT_MAX_LENGTH:Int = 50;

	public var max:Int;

	public function new() {
		super(AST);
		max = DEFAULT_MAX_LENGTH;
		categories = ["Complexity", "Clarity"];
		points = 8;
	}

	override public function actualRun() {
		forEachField(searchField);
	}

	function searchField(f:Field, _) {
		switch (f.kind){
			case FFun(ff):
				checkMethod(f);
			default:
		}

		ExprUtils.walkField(f, function(e) {
			switch (e.expr){
				case EFunction(name, ff):
					checkFunction(e);
				default:
			}
		});
	}

	function checkMethod(f:Field) {
		var lp = checker.getLinePos(f.pos.min);
		var lmin = lp.line;
		var lmax = checker.getLinePos(f.pos.max).line;
		if (lmax - lmin > max) warnFunctionLength(f.name, f.pos);
	}

	function checkFunction(f:Expr) {
		var lp = checker.getLinePos(f.pos.min);
		var lmin = lp.line;
		var lmax = checker.getLinePos(f.pos.max).line;
		var fname = "(anonymous)";
		switch (f.expr){
			case EFunction(name, ff):
				if (name != null) fname = name;
			default: throw "EFunction only";
		}

		if (lmax - lmin > max) warnFunctionLength(fname, f.pos);
	}

	function warnFunctionLength(name:String, pos:Position) {
		logPos('Function is too long: ${name} (> ${max} lines, try splitting into multiple functions)', pos);
	}
}