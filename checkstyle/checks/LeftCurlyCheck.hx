package checkstyle.checks;

import checkstyle.Checker.LinePos;
import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data;
import haxe.macro.Expr;

@name("LeftCurly")
@desc("Checks for placement of left curly braces")
class LeftCurlyCheck extends Check {

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

	public static inline var EOL:String = "eol";
	public static inline var NL:String = "nl";

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
			//OBJECT_DECL, // => allow inline object declarations
			FUNCTION,
			FOR,
			IF,
			WHILE,
			SWITCH,
			TRY,
			CATCH
		];
		option = EOL;
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
					if (d.data.length == 0) {
						checkLinesBetween(td.pos.min, td.pos.max, td.pos);
						return;
					}
					checkLinesBetween(td.pos.min, d.data[0].pos.min, td.pos);
				case EEnum(d):
					if (!hasToken(ENUM_DEF)) return;
					if (d.data.length == 0) {
						checkLinesBetween(td.pos.min, td.pos.max, td.pos);
						return;
					}
					checkLinesBetween(td.pos.min, d.data[0].pos.min, td.pos);
				case EAbstract(d):
					checkFields(d.data);
					if (!hasToken(ABSTRACT_DEF)) return;
					if (d.data.length == 0) {
						checkLinesBetween(td.pos.min, td.pos.max, td.pos);
						return;
					}
					checkLinesBetween(td.pos.min, d.data[0].pos.min, td.pos);
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
					checkBlocks(f.expr);
				default:
			}
		}
	}

	function checkTypeDef(td:TypeDecl) {
		var firstPos:Position = null;

		ComplexTypeUtils.walkTypeDecl(td, function(t:ComplexType, name:String, pos:Position) {
			if (firstPos == null) {
				if (pos != td.pos) firstPos = pos;
			}
			if (!hasToken(OBJECT_DECL)) return;
			switch(t) {
				case TAnonymous(_):
					checkLinesBetween(pos.min, pos.max, pos);
				default:
			}
		});
		if (firstPos == null) return;
		if (!hasToken(TYPEDEF_DEF)) return;
		checkLinesBetween(td.pos.max, firstPos.min, td.pos);
	}

	function walkFile() {
		ExprUtils.walkFile(checker.ast, function(e) {
			if (isPosSuppressed(e.pos)) return;
			switch(e.expr) {
				case EObjectDecl(fields):
					if (!hasToken(OBJECT_DECL)) return;
					var linePos:LinePos = checker.getLinePos(e.pos.min);
					var line:String = checker.lines[linePos.line];
					checkLeftCurly(line, e.pos);
				case EFunction(_, f):
					if (!hasToken(FUNCTION)) return;
					checkBlocks(f.expr);
				case EFor(it, expr):
					if (!hasToken(FOR)) return;
					checkBlocks(expr);
				case EIf(econd, eif, eelse):
					if (!hasToken(IF)) return;
					checkBlocks(eif);
					checkBlocks(eelse);
				case EWhile(econd, expr, _):
					if (!hasToken(WHILE)) return;
					checkBlocks(expr);
				case ESwitch(expr, cases, edef):
					if (!hasToken(SWITCH)) return;
					var firstCase:Expr = edef;
					if (cases.length > 0) {
						firstCase = cases[0].values[0];
					}
					if (firstCase == null) {
						checkLinesBetween(e.pos.min, e.pos.max, e.pos);
						return;
					}
					checkLinesBetween(expr.pos.max, firstCase.pos.min, e.pos);
				case ETry(expr, catches):
					if (!hasToken(TRY)) return;
					checkBlocks(expr);
					for (ecatch in catches) {
						checkBlocks(ecatch.expr);
					}
				default:
			}
		});
	}

	function checkBlocks(e:Expr) {
		if ((e == null) || (e.expr == null)) return;

		switch(e.expr) {
			case EBlock(_):
				var linePos:LinePos = checker.getLinePos(e.pos.min);
				var line:String = checker.lines[linePos.line];
				checkLeftCurly(line, e.pos);
			default:
		}
	}

	function checkLinesBetween(min:Int, max:Int, pos:Position) {
		if (isPosSuppressed(pos)) return;
		var bracePos:Int = checker.file.content.lastIndexOf("{", max);
		if (bracePos < 0 || bracePos < min) return;

		var lineNum:Int = checker.getLinePos(bracePos).line;
		var line:String = checker.lines[lineNum];
		checkLeftCurly(line, pos);
	}

	@SuppressWarnings("checkstyle:BlockFormat")
	function checkLeftCurly(line:String, pos:Position) {
		var lineLength:Int = line.length;

		// must have at least one non whitespace character before curly
		// and only whitespace, } or // + comment after curly
		var curlyAtEOL:Bool = ~/^\s*\S.*\{\}?\s*(|\/\/.*)$/.match(line);
		// must have only whitespace before curly
		var curlyOnNL:Bool = ~/^\s*\{\}?/.match(line);

		try {
			if (curlyAtEOL) {
				logErrorIf ((option == NL), 'Left curly should be on new line (only whitespace before curly)', pos);
				logErrorIf ((option != EOL), 'Left curly unknown option ${option}', pos);
				return;
			}
			logErrorIf ((option == EOL), 'Left curly should be at EOL (only linebreak or comment after curly)', pos);
			logErrorIf ((!curlyOnNL), 'Left curly should be on new line (only whitespace before curly)', pos);
			logErrorIf ((option != NL), 'Left curly unknown option ${option}', pos);
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