package checkstyle.checks;

import checkstyle.Checker.LinePos;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("RightCurly")
@desc("Checks for placement of right curly braces")
class RightCurlyCheck extends Check {

	public static inline var CLASS_DEF:String = "CLASS_DEF";
	public static inline var ENUM_DEF:String = "ENUM_DEF";
	public static inline var ABSTRACT_DEF:String = "ABSTRACT_DEF";
	public static inline var TYPEDEF_DEF:String = "TYPEDEF_DEF";
	public static inline var INTERFACE_DEF:String = "INTERFACE_DEF";

	public static inline var OBJECT_DECL:String = "OBJECT_DECL";
	public static inline var FUNCTION:String = "FUNCTION";
	public static inline var FOR:String = "FOR";
	public static inline var IF:String = "IF";
	public static inline var WHILE:String = "WHILE";
	public static inline var SWITCH:String = "SWITCH";
	public static inline var TRY:String = "TRY";
	public static inline var CATCH:String = "CATCH";

	public static inline var SAME:String = "same";
	public static inline var ALONE:String = "alone";
	public static inline var ALONE_OR_SINGLELINE:String = "aloneorsingle";

	var sameRegex:EReg;

	public var tokens:Array<String>;
	public var option:String;

	public function new() {
		super();
		tokens = [
			CLASS_DEF,
			ENUM_DEF,
			ABSTRACT_DEF,
			TYPEDEF_DEF,
			INTERFACE_DEF,
			OBJECT_DECL,
			FUNCTION,
			FOR,
			IF,
			WHILE,
			SWITCH,
			TRY,
			CATCH
		];
		option = ALONE_OR_SINGLELINE;

		// only else and catch allowed on same line after a right curly
		sameRegex = ~/^\s*(else|catch)/;
	}

	function hasToken(token:String):Bool {
		if (tokens.length == 0) return true;
		if (tokens.indexOf(token) > -1) return true;
		return false;
	}

	override function actualRun() {
		walkDecl();
		walkFile();
	}

	function walkDecl() {
		for (td in checker.ast.decls) {
			switch(td.decl) {
				case EClass(d):
					checkFields(d.data);
					if (d.flags.indexOf(HInterface) > -1 && !hasToken(INTERFACE_DEF)) return;
					if (d.flags.indexOf(HInterface) < 0 && !hasToken(CLASS_DEF)) return;
					checkPos(td.pos, isSingleLine (td.pos.min, td.pos.max));
				case EEnum(d):
					if (!hasToken(ENUM_DEF)) return;
					checkPos(td.pos, isSingleLine (td.pos.min, td.pos.max));
				case EAbstract(d):
					checkFields(d.data);
					if (!hasToken(ABSTRACT_DEF)) return;
					checkPos(td.pos, isSingleLine (td.pos.min, td.pos.max));
				case ETypedef (d):
					checkTypeDef(td);
				default:
			}
		}
	}

	function checkFields(fields:Array<Field>) {
		for (field in fields) {
			if (isCheckSuppressed(field)) return;
			switch (field.kind) {
				case FFun(f):
					if (!hasToken(FUNCTION)) return;
					if (f.expr == null) return;
					checkBlocks(f.expr, isSingleLine (f.expr.pos.min, f.expr.pos.max));
				default:
			}
		}
	}

	function checkTypeDef(td:TypeDecl) {
		var firstPos:Position = null;
		var maxPos:Int = td.pos.max;

		ComplexTypeUtils.walkTypeDecl(td, function(t:ComplexType, name:String, pos:Position) {
			if (firstPos == null) {
				if (pos != td.pos) firstPos = pos;
			}
			if (pos.max > maxPos) maxPos = pos.max;
			if (!hasToken(OBJECT_DECL)) return;
			switch (t) {
				case TAnonymous(_):
					checkPos(pos, isSingleLine(pos.min, pos.max));
				default:
			}
		});
		if (firstPos == null) return;
		if (!hasToken(TYPEDEF_DEF)) return;
		// td.pos only holds pos info about the type itself
		// members only hold pos info about themself
		// so real pos.max is pos.max of last member + 1
		td.pos.max = checker.file.content.indexOf ('}', maxPos - 1);
		checkPos(td.pos, isSingleLine (td.pos.min, td.pos.max));
	}

	function walkFile() {
		ExprUtils.walkFile(checker.ast, function(e) {
			if (isPosSuppressed(e.pos)) return;
			switch (e.expr) {
				case EObjectDecl(fields):
					if (!hasToken(OBJECT_DECL)) return;
					if (fields.length <= 0) return;
					var lastExpr:Expr = fields[fields.length - 1].expr;
					checkBlocks(e, isSingleLine(e.pos.min, e.pos.max));
				case EFunction(_, f):
					if (!hasToken(FUNCTION)) return;
					checkBlocks(f.expr, isSingleLine(e.pos.min, f.expr.pos.max));
				case EFor(it, expr):
					if (!hasToken(FOR)) return;
					checkBlocks(expr, isSingleLine(e.pos.min, expr.pos.max));
				case EIf(econd, eif, eelse):
					if (!hasToken(IF)) return;
					var singleLine:Bool;
					if (eelse != null) singleLine = isSingleLine(e.pos.min, eelse.pos.max);
					else singleLine = isSingleLine (e.pos.min, eif.pos.max);
					checkBlocks(eif, singleLine);
					if (eelse != null) checkBlocks(eelse, singleLine);
				case EWhile(econd, expr, _):
					if (!hasToken(WHILE)) return;
					checkBlocks(expr, isSingleLine(e.pos.min, expr.pos.max));
				case ESwitch(expr, cases, edef):
					if (!hasToken(SWITCH)) return;
					checkPos(e.pos, isSingleLine(e.pos.min, e.pos.max));
					for (c in cases) {
						if (c.expr != null) checkBlocks(c.expr, isSingleLine(c.expr.pos.min, c.expr.pos.max));
					}
					if ((edef == null) || (edef.expr == null)) return;
					checkBlocks (edef, isSingleLine(edef.pos.min, edef.pos.max));
				case ETry(expr, catches):
					if (!hasToken(TRY)) return;
					checkBlocks(expr, isSingleLine(e.pos.min, expr.pos.max));
					for (ecatch in catches) {
						checkBlocks(ecatch.expr, isSingleLine(e.pos.min, ecatch.expr.pos.max));
					}
				default:
			}
		});
	}

	function checkPos(pos:Position, singleLine:Bool) {
		if (isPosSuppressed(pos)) return;
		var bracePos:Int = checker.file.content.lastIndexOf("}", pos.max);
		if (bracePos < 0 || bracePos < pos.min) return;

		if (pos.max >= checker.file.content.length) pos.max = checker.file.content.length - 1;
		var linePos:Int = checker.getLinePos(pos.max).line;
		var line:String = checker.lines[linePos];
		checkRightCurly(line, singleLine, pos);
	}

	function checkBlocks(e:Expr, singleLine:Bool) {
		if ((e == null) || (e.expr == null)) return;
		var bracePos:Int = checker.file.content.lastIndexOf("}", e.pos.max);
		if (bracePos < 0 || bracePos < e.pos.min) return;

		switch (e.expr) {
			case EBlock(_), EObjectDecl(_):
				var linePos:Int = checker.getLinePos(e.pos.max).line;
				var line:String = checker.lines[linePos];
				checkRightCurly(line, singleLine, e.pos);
			default:
		}
	}

	function isSingleLine(start:Int, end:Int):Bool {
		var startLine:Int = checker.getLinePos(start).line;
		if (end >= checker.file.content.length) end = checker.file.content.length - 1;
		var endLine:Int = checker.getLinePos(end).line;
		return startLine == endLine;
	}

	function checkRightCurly(line:String, singleLine:Bool, pos:Position) {
		try {
			var eof:Bool = false;
			if (pos.max >= checker.file.content.length) {
				pos.max = checker.file.content.length - 1;
				eof = true;
			}
			var linePos:LinePos = checker.getLinePos(pos.max);
			var afterCurly:String = "";
			if (!eof) {
				var afterLine:String = checker.lines[linePos.line];
				if (linePos.ofs < afterLine.length) afterCurly = afterLine.substr(linePos.ofs);
			}
			var needsSameOption:Bool = sameRegex.match(afterCurly);
			var shouldHaveSameOption:Bool = false;
			if (checker.lines.length > linePos.line + 1) {
				var nextLine:String = checker.lines[linePos.line + 1];
				shouldHaveSameOption = sameRegex.match(nextLine);
			}
			// adjust to show correct line number in log message
			pos.min = pos.max;

			logErrorIf (singleLine && (option != ALONE_OR_SINGLELINE), 'Right curly should not be on same line as left curly', pos);
			if (singleLine) return;

			var curlyAlone:Bool = ~/^\s*\}[\)\],;\s]*(|\/\/.*)$/.match(line);
			logErrorIf (!curlyAlone && (option == ALONE_OR_SINGLELINE || option == ALONE), 'Right curly should be alone on a new line', pos);
			logErrorIf (curlyAlone && needsSameOption, 'Right curly should be alone on a new line', pos);
			logErrorIf (needsSameOption && (option != SAME), 'Right curly must not be on same line as following block', pos);
			logErrorIf (shouldHaveSameOption && (option == SAME), 'Right curly should be on same line as following block (e.g. "} else" or "} catch")', pos);
		}
		catch (e:String) {
			// one of the error messages fired -> do nothing
		}
	}

	function logErrorIf(condition:Bool, msg:String, pos:Position) {
		if (condition) {
			logPos(msg, pos, Reflect.field(SeverityLevel, severity));
			throw "exit";
		}
	}
}