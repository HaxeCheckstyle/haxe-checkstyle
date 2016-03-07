package checkstyle.checks.block;

import checkstyle.Checker.LinePos;
import checkstyle.LintMessage.SeverityLevel;
import checkstyle.token.TokenTree;
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
	public static inline var REIFICATION:String = "REIFICATION";
	public static inline var ARRAY_COMPREHENSION:String = "ARRAY_COMPREHENSION";

	public static inline var SAME:String = "same";
	public static inline var ALONE:String = "alone";
	public static inline var ALONE_OR_SINGLELINE:String = "aloneorsingle";

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
	}

	function hasToken(token:String):Bool {
		return (tokens.length == 0 || tokens.indexOf(token) > -1);
	}

	override function actualRun() {
		var root:TokenTree = checker.getTokenTree();
		var allBrClose:Array<TokenTree> = root.filter([BrClose], ALL);

		for (brClose in allBrClose) {
			if (isPosSuppressed(brClose.pos)) continue;
			var brOpen:TokenTree = brClose.parent;
			if (filterParentToken(brOpen.parent)) continue;
			check(brClose, isSingleLine(brOpen.pos.min, brClose.pos.max));
		}
	}

	@SuppressWarnings("checkstyle:CyclomaticComplexity")
	function filterParentToken(token:TokenTree):Bool {
		if (token == null) return false;
		switch (token.tok) {
			case Kwd(KwdClass):
				return !hasToken(CLASS_DEF);
			case Kwd(KwdInterface):
				return !hasToken(INTERFACE_DEF);
			case Kwd(KwdAbstract):
				return !hasToken(ABSTRACT_DEF);
			case Kwd(KwdTypedef):
				return !hasToken(TYPEDEF_DEF);
			case Kwd(KwdEnum):
				return !hasToken(ENUM_DEF);
			case Kwd(KwdFunction):
				return !hasToken(FUNCTION);
			case Kwd(KwdIf), Kwd(KwdElse):
				return !hasToken(IF);
			case Kwd(KwdFor):
				if (isArrayComprehension(token.parent)) {
					return !hasToken(ARRAY_COMPREHENSION);
				}
				return !hasToken(FOR);
			case Kwd(KwdWhile):
				return !hasToken(WHILE);
			case Kwd(KwdTry):
				return !hasToken(TRY);
			case Kwd(KwdCatch):
				return !hasToken(CATCH);
			case Kwd(KwdSwitch), Kwd(KwdCase), Kwd(KwdDefault):
				return !hasToken(SWITCH);
			case POpen, BkOpen, BrOpen, Kwd(KwdReturn):
				return !hasToken(OBJECT_DECL);
			case Dollar(_):
				return !hasToken(REIFICATION);
			case Binop(OpAssign):
				// could be OBJECT_DECL or TYPEDEF_DEF
				if ((token.parent != null) && (token.parent.parent != null)) {
					switch (token.parent.parent.tok) {
						case Kwd(KwdTypedef):
							return !hasToken(TYPEDEF_DEF);
						default:
					}
				}
				return !hasToken(OBJECT_DECL);
			default:
				return filterParentToken(token.parent);
		}
	}

	function isArrayComprehension(token:TokenTree):Bool {
		return switch (token.tok) {
			case BkOpen: true;
			case Kwd(KwdFunction): false;
			case Kwd(KwdVar): false;
			default: isArrayComprehension(token.parent);
		}
	}

	function check(token:TokenTree, singleLine:Bool) {
		var lineNum:Int = checker.getLinePos(token.pos.min).line;
		var line:String = checker.lines[lineNum];
		checkRightCurly(line, singleLine, token.pos);
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
			// only else and catch allowed on same line after a right curly
			var sameRegex = ~/^\s*(else|catch)/;
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
			logPos(msg, pos, severity);
			throw "exit";
		}
	}
}