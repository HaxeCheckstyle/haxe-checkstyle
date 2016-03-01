package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.Position;
using haxe.macro.ExprTools;

@name("NullParameter")
@desc("Checks for parameters with a null default value")
class NullParameterCheck extends Check {

	public static inline var EITHER:String = "either";
	public static inline var QUESTION_MARK:String = "questionmark";
	public static inline var NULL:String = "null";

	public var nullDefaultValueStyle:String;

	public function new() {
		super();
		nullDefaultValueStyle = QUESTION_MARK;
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
		var prefix = 'Parameter \'${arg.name}\' ';
		if (arg.opt && hasNullDefault) {
			logPos(prefix + "is marked as optional with '?' and has a default value of 'null', which is redundant",
				arg.value.pos, Reflect.field(SeverityLevel, severity));
		}
		else {
			var line = checker.getLinePos(pos.min).line + 1;
			if (hasNullDefault && nullDefaultValueStyle == QUESTION_MARK) {
				log(prefix + "should be marked as optional with '?' instead of using a null default value",
					line, 0, null, Reflect.field(SeverityLevel, severity));
			}
			else if (arg.opt && nullDefaultValueStyle == NULL) {
				log(prefix + "should have a null default value instead of being marked as optional with '?'",
					line, 0, null, Reflect.field(SeverityLevel, severity));
			}
		}
	}
}