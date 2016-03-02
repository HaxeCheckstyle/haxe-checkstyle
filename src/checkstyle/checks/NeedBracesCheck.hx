package checkstyle.checks;

import checkstyle.Checker.LinePos;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("NeedBraces")
@desc("Checks for braces on if, if else, for and while statements")
class NeedBracesCheck extends Check {

	public static inline var FOR:String = "FOR";
	public static inline var IF:String = "IF";
	public static inline var ELSE_IF:String = "ELSE_IF";
	public static inline var WHILE:String = "WHILE";

	public var tokens:Array<String>;
	public var allowSingleLineStatement:Bool;

	public function new() {
		super();
		tokens = [];
		allowSingleLineStatement = true;
	}

	function hasToken(token:String):Bool {
		if (tokens.length == 0) return true;
		if (tokens.indexOf(token) > -1) return true;
		return false;
	}

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e) {
			if (isPosSuppressed(e.pos)) return;
			switch(e.expr) {
				case EFor(it, expr):
					if (!hasToken(FOR)) return;
					var itLine:LinePos = checker.getLinePos(it.pos.max);
					var exprLine:LinePos = checker.getLinePos(expr.pos.min);
					checkBraces(expr, 'for loop', itLine.line == exprLine.line, false);
				case EIf(econd, eif, eelse):
					if (!hasToken(IF)) return;
					var condLine:LinePos = checker.getLinePos(econd.pos.max);
					var ifLine:LinePos = checker.getLinePos(eif.pos.min);
					var elseSameLine:Bool = false;
					if (eelse != null) {
						var elseLine:LinePos = checker.getLinePos(eelse.pos.min);
						var line:String = checker.lines[elseLine.line];
						if (StringTools.startsWith(StringTools.trim(line), "else")) elseSameLine = true;
					}
					checkBraces(eif, 'if branch', condLine.line == ifLine.line, true);
					checkBraces(eelse, 'else branch', elseSameLine, true);
				case EWhile(econd, expr, _):
					if (!hasToken(WHILE)) return;
					var condLine:LinePos = checker.getLinePos(econd.pos.max);
					var exprLine:LinePos = checker.getLinePos(expr.pos.min);
					checkBraces(expr, 'while loop', condLine.line == exprLine.line, false);
				default:
			}
		});
	}

	@SuppressWarnings("checkstyle:CyclomaticComplexity")
	function checkBraces(e:Expr, name:String, sameLine:Bool, parentIsIf:Bool) {
		if ((e == null) || (e.expr == null)) return;

		var minLine:LinePos = checker.getLinePos(e.pos.min);
		var maxLine:LinePos = checker.getLinePos(e.pos.max);
		var multiLine:Bool = (minLine.line < maxLine.line);
		switch (e.expr) {
			case EBlock(_):
				if (!multiLine && !allowSingleLineStatement) {
					logPos('Single line Block detected', e.pos, Reflect.field(SeverityLevel, severity));
				}
				return;
			case EIf(_, _, _):
				if (!parentIsIf || !hasToken(ELSE_IF)) {
					if (multiLine) sameLine = false;
				}
				if (sameLine && allowSingleLineStatement) return;
				if (sameLine && !allowSingleLineStatement) {
					logPos('Body of $name on same line', e.pos, Reflect.field(SeverityLevel, severity));
					return;
				}
				logPos('No braces used for body of $name', e.pos, Reflect.field(SeverityLevel, severity));
			default:
				if (multiLine) sameLine = false;
				if (sameLine && allowSingleLineStatement) return;
				if (sameLine && !allowSingleLineStatement) {
					logPos('Body of $name on same line', e.pos, Reflect.field(SeverityLevel, severity));
					return;
				}
				logPos('No braces used for body of $name', e.pos, Reflect.field(SeverityLevel, severity));
		}
	}
}