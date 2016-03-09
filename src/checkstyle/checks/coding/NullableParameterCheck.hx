package checkstyle.checks.coding;

import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.Position;
using haxe.macro.ExprTools;

@name("NullableParameter")
@desc("Enforces a style for nullable parameters")
class NullableParameterCheck extends Check {

	public var option:NullableParameterCheckOption;

	public function new() {
		super(AST);
		option = QUESTION_MARK;
	}

	override function actualRun() {
		forEachField(function(field, _) {
			switch (field.kind) {
				case FFun(f):
					for (arg in f.args) checkArgument(arg, field.pos);
				case _:
			}
		});
	}

	function checkArgument(arg:FunctionArg, pos:Position) {
		var hasNullDefault = arg.value.toString() == "null";
		if (!hasNullDefault && arg.value != null) return;
		var formatted = formatArguments(arg.opt, arg.name, hasNullDefault);

		switch (option) {
			case QUESTION_MARK:
				if (hasNullDefault) logRange('Function parameter $formatted should be ${formatArguments(true, arg.name, false)}', pos.min, pos.min);
			case NULL_DEFAULT:
				if (arg.opt) logRange('Function parameter $formatted should be ${formatArguments(false, arg.name, true)}', pos.min, pos.min);
		}
	}

	function formatArguments(opt:Bool, name:String, nullDefault:Bool):String {
		return "'" + (opt ? "?" : "") + name + (nullDefault ? " = null" : "") + "'";
	}
}

@:enum
abstract NullableParameterCheckOption(String) {
	var QUESTION_MARK = "questionMark";
	var NULL_DEFAULT = "nullDefault";
}