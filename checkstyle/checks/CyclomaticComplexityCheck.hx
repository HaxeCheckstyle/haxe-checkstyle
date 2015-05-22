package checkstyle.checks;

import haxeparser.Data.TypeDecl;
import haxeparser.Data.TypeDef;
import haxeparser.Data.Definition;
import haxeparser.Data.ClassFlag;
import checkstyle.LintMessage.SeverityLevel;
import haxe.macro.Expr;

using Lambda;

@name("CyclomaticComplexity")
@desc("McCabe simplified cyclomatic complexity check")
class CyclomaticComplexityCheck extends Check {

	public var thresholds:Array<Threshold> = [
		{ severity : "WARNING", complexity : 11 },
		{ severity : "ERROR", complexity : 21 }
	];

	override function _actualRun() {
		_checker.ast.decls.map(function(type:TypeDecl):Null<Definition<ClassFlag, Array<Field>>> {
			return switch (type.decl) {
				case TypeDef.EClass(definition): definition;
				default: null;
			}
		}).filter(function(definition):Bool {
			return definition != null;
		}).iter(checkFields);
	}

	function checkFields(definition:Definition<ClassFlag, Array<Field>>) {
		definition.data.map(function(field:Field):Null<Target> {
			return switch (field.kind) {
				case FieldType.FFun(f): {name:field.name, expr:f.expr, pos:field.pos};
				default: null;
			}
		}).filter(function(f:Null<Target>):Bool {
			return f != null;
		}).iter(calculateComplexity);
	}

	function calculateComplexity(method:Target) {
		var complexity:Int = 1 + evaluateExpr(method.expr);
		
		var risk:Null<Threshold> = thresholds.filter(function(t:Threshold):Bool {
			return complexity >= t.complexity;
		}).pop();
		
		if (risk != null) {
			notify(method, complexity, risk);
		}
	}
	
	// This would not pass the cyclomatic complexity test.
	function evaluateExpr(e:Expr):Int {
		if (e == null || e.expr == null) {
			return 0;
		}
		return switch(e.expr) {
			case ExprDef.EArray(e1, e2) : evaluateExpr(e1) + evaluateExpr(e2);
			case ExprDef.EBinop(op, e1, e2) : evaluateExpr(e1) + evaluateExpr(e2) + switch(op) {
				case Binop.OpBoolAnd : 1;
				case Binop.OpBoolOr : 1;
				default : 0;
			};
			case ExprDef.EParenthesis(e) : evaluateExpr(e);
			case ExprDef.EObjectDecl(fields) : 
				fields.map(function(f):Expr { 
					return f.expr; 
				}).fold(function(e:Expr, total:Int):Int {
					return total + evaluateExpr(e);
				}, 0);
			case ExprDef.EArrayDecl(values) :
				values.fold(function(e:Expr, total:Int):Int {
					return total + evaluateExpr(e);
				}, 0);
			case ExprDef.EBlock(exprs) :
				exprs.fold(function(e:Expr, total:Int):Int {
					return total + evaluateExpr(e);
				}, 0);
			case ExprDef.EFor(it, e) : 1 + evaluateExpr(it) + evaluateExpr(e);
			case ExprDef.EIn(e1, e2) : evaluateExpr(e1) + evaluateExpr(e2);
			case ExprDef.EIf(econd, eif, eelse) : 1 + evaluateExpr(econd) + evaluateExpr(eif) + evaluateExpr(eelse);
			case ExprDef.EWhile(econd, e, _) : 1 + evaluateExpr(econd) + evaluateExpr(e);
			case ExprDef.ESwitch(e, cases, def) :
				evaluateExpr(def) + cases.map(function(c:Case):Expr {
					return c.expr;
				}).fold(function(e:Expr, total:Int):Int {
					return total + 1 + evaluateExpr(e);
				}, 0);
			case ExprDef.ETry(e, catches) :
				catches.map(function(c:Catch):Expr {
					return c.expr;
				}).fold(function(e:Expr, total:Int):Int {
					return total + 1 + evaluateExpr(e);
				}, 0);
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
		logPos('Function \"${method.name}\" is too complex (score: $complexity).', method.pos, Reflect.field(SeverityLevel, risk.severity));
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
