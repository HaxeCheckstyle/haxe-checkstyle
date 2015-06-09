package checkstyle.checks;

import String;
import checkstyle.LintMessage.SeverityLevel;
import haxe.macro.Expr;
import haxeparser.Data;

@name("Return")
@desc("Warns if Void is used for return or if return type is not specified when returning")
class ReturnCheck extends Check {

	public var allowEmptyReturn:Bool;
	public var enforceReturnType:Bool;

	public function new() {
		super();
		allowEmptyReturn = true;
		enforceReturnType = false;
	}

	override function actualRun() {
		for (td in checker.ast.decls) {
			switch(td.decl){
				case EClass(d):
					checkFields(d);
				default:
			}
		}
		checkInlineFunctions();
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			if (isCheckSuppressed(field)) continue;
			if (field.name != "new" && d.flags.indexOf(HInterface) == -1) checkField(field);
		}
	}

	function checkField(f:Field) {
		var noReturn = false;
		switch(f.kind) {
			case FFun(fun):
				noReturn = (fun.ret == null);
				if (enforceReturnType && noReturn) {
					warnReturnTypeMissing(f.name, f.pos);
					return;
				}

				if (!noReturn) {
					switch(fun.ret) {
						case TPath(val):
							if (!enforceReturnType && Std.string(val.name) == "Void") warnVoid(f.name, f.pos);
						default:
					}
				}

				walkExpr(fun.expr, noReturn, f.name, f.pos);
			default:
		}
	}

	function checkInlineFunctions() {
		ExprUtils.walkFile(checker.ast, function(e) {
			switch(e.expr) {
				case EFunction(fname, f):
					var funNoReturn:Bool = (f.ret == null);
					walkExpr (f.expr, funNoReturn, fname, e.pos);
				default:
			}
		});
	}

	@SuppressWarnings("checkstyle:CyclomaticComplexity")
	function walkExpr(e:Expr, noReturn:Bool, name:String, pos:Position) {
		if ((e == null) || (e.expr == null)) {
			return;
		}
		// function has a return, no need to dig deeper
		// -> compiler will complain if types do not match
		if (!noReturn) return;
		switch(e.expr) {
			case EBlock(exprs):
				for (expr in exprs) {
					walkExpr(expr, noReturn, name, pos);
				}
			case EFor(it, expr):
				walkExpr(expr, noReturn, name, pos);
			case EIf(econd, eif, eelse):
				walkExpr(eif, noReturn, name, pos);
				walkExpr(eelse, noReturn, name, pos);
			case EWhile(econd, expr, _):
				walkExpr(expr, noReturn, name, pos);
			case ESwitch(expr, cases, edef):
				for (ecase in cases) {
					walkExpr(ecase.expr, noReturn, name, pos);
				}
				walkExpr(edef, noReturn, name, pos);
			case ETry(expr, catches):
				walkExpr(expr, noReturn, name, pos);
				for (ecatch in catches) {
					walkExpr(ecatch.expr, noReturn, name, pos);
				}
			case EReturn(expr):
				if (noReturn && allowEmptyReturn && expr == null) return;
				else if (noReturn) {
					warnReturnTypeMissing(name, pos);
				}
			default:
		}
	}

	function warnVoid(name:String, pos:Position) {
		logPos('No need to return Void, Default function return value type is Void: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}

	function warnReturnTypeMissing(name:String, pos:Position) {
		if (name == null) {
			logPos('Return type not specified for anonymous function', pos, Reflect.field(SeverityLevel, severity));
		}
		else {
			logPos('Return type not specified for function: ${name}', pos, Reflect.field(SeverityLevel, severity));
		}
	}
}