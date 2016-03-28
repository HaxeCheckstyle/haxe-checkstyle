package checkstyle.checks.metrics;

import haxe.macro.Expr;

import checkstyle.CheckMessage.SeverityLevel;

using Lambda;

@name("CyclomaticComplexity")
@desc("Checks the complexity of methods using McCabe simplified cyclomatic complexity check. Complexity levels can be customised using `thresholds` property.")
class CyclomaticComplexityCheck extends Check {

	static var DEFAULT_COMPLEXITY_WARNING:Int = 20;
	static var DEFAULT_COMPLEXITY_ERROR:Int = 25;

	public var thresholds:Array<Threshold>;

	public function new() {
		super(AST);
		thresholds = [
			{ severity : "WARNING", complexity : DEFAULT_COMPLEXITY_WARNING },
			{ severity : "ERROR", complexity : DEFAULT_COMPLEXITY_ERROR }
		];
		categories = [Category.COMPLEXITY];
		points = 13;
	}

	override function actualRun() {
		forEachField(function(field, _) {
			switch (field.kind) {
				case FieldType.FFun(f):
					calculateComplexity({ name:field.name, expr:f.expr, pos:field.pos});
				default:
			}
		});
	}

	function calculateComplexity(method:Target) {
		var complexity:Int = 1 + evaluateExpr(method.expr);

		var risk:Null<Threshold> = thresholds.filter(function(t:Threshold):Bool {
			return (complexity >= t.complexity) && (t.severity != SeverityLevel.IGNORE);
		}).pop();

		if (risk != null) {
			notify(method, complexity, risk);
		}
	}

	// This would not pass the cyclomatic complexity test.
	function evaluateExpr(e:Expr):Int {
		if (e == null || e.expr == null) return 0;
		return switch (e.expr) {
			case ExprDef.EArray(e1, e2) : evaluateExpr(e1) + evaluateExpr(e2);
			case ExprDef.EBinop(op, e1, e2) : evaluateExpr(e1) + evaluateExpr(e2) + switch (op) {
				case Binop.OpBoolAnd : 1;
				case Binop.OpBoolOr : 1;
				default : 0;
			};
			case ExprDef.EParenthesis(e) : evaluateExpr(e);
			case ExprDef.EObjectDecl(fields) :
				fields.map(function(f):Expr {
					return f.expr;
				}).fold(function(e:Expr, total:Int):Int { return total + evaluateExpr(e); }, 0);
			case ExprDef.EArrayDecl(values) :
				values.fold(function(e:Expr, total:Int):Int { return total + evaluateExpr(e); }, 0);
			case ExprDef.EBlock(exprs) :
				exprs.fold(function(e:Expr, total:Int):Int { return total + evaluateExpr(e); }, 0);
			case ExprDef.EFor(it, e) : 1 + evaluateExpr(it) + evaluateExpr(e);
			case ExprDef.EIn(e1, e2) : evaluateExpr(e1) + evaluateExpr(e2);
			case ExprDef.EIf(econd, eif, eelse) : 1 + evaluateExpr(econd) + evaluateExpr(eif) + evaluateExpr(eelse);
			case ExprDef.EWhile(econd, e, _) : 1 + evaluateExpr(econd) + evaluateExpr(e);
			case ExprDef.ESwitch(e, cases, def) :
				evaluateExpr(def) + cases.map(function(c:Case):Expr {
					return c.expr;
				}).fold(function(e:Expr, total:Int):Int { return total + 1 + evaluateExpr(e); }, 0);
			case ExprDef.ETry(e, catches) :
				catches.map(function(c:Catch):Expr {
					return c.expr;
				}).fold(function(e:Expr, total:Int):Int { return total + 1 + evaluateExpr(e); }, 0);
			case ExprDef.EReturn(e) : (e != null) ? evaluateExpr(e) : 0;
			case ExprDef.EUntyped(e) : evaluateExpr(e);
			case ExprDef.EThrow(e) : evaluateExpr(e);
			case ExprDef.ECast(e, _) : evaluateExpr(e);
			case ExprDef.EDisplay(e, _) : evaluateExpr(e);
			case ExprDef.ETernary(econd, eif, eelse) : 1 + evaluateExpr(econd) + evaluateExpr(eif) + evaluateExpr(eelse);
			case ExprDef.ECheckType(e, _) : evaluateExpr(e);
			default: 0;
		}
	}

	function notify(method:Target, complexity:Int, risk:Threshold) {
		logPos('Method "${method.name}" is too complex (score: $complexity).', method.pos, risk.severity);
	}
}

typedef Target = {
	var name:String;
	var expr:Expr;
	var pos:Position;
}

typedef Threshold = {
	var severity:String;
	var complexity:Int;
}