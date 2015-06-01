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
			switch (td.decl){
				case EClass(d):
					checkFields(d);
				default:
			}
		}
	}

	function checkFields(d:Definition<ClassFlag, Array<Field>>) {
		for (field in d.data) {
			if (isCheckSuppressed(field)) continue;
			if (field.name != "new" && d.flags.indexOf(HInterface) == -1) checkField(field);
		}
	}
	
	function checkField(f:Field) {
		var noReturn = false;
		switch (f.kind) {
			case FFun(fun):
				noReturn = (fun.ret == null);
				if (enforceReturnType && fun.ret == null) {
					warnReturnTypeMissing(f.name, f.pos);
					return;
				}
			
				switch (fun.ret) {
					case TPath(val):
						if (!enforceReturnType && Std.string(val.name) == "Void") warnVoid(f.name, f.pos);
					default:
				}

				switch (fun.expr.expr) {
					case EBlock(fields):
						for (field in fields) {
							switch (field.expr) {
								case EReturn(val):
									if (noReturn && allowEmptyReturn && val == null) return;
									else if (noReturn) {
										warnReturnTypeMissing(f.name, f.pos);
									}
								default:
							}
						}
					default:
				}
			default:
		}
	}

	function warnVoid(name:String, pos:Position) {
		logPos('No need to return Void, Default function return value type is Void: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}

	function warnReturnTypeMissing(name:String, pos:Position) {
		logPos('Return type not specified for function: ${name}', pos, Reflect.field(SeverityLevel, severity));
	}
}