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
	public static inline var NLOW:String = "nlow";

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
					checkBlocks(f.expr, isFieldWrapped(field));
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
					checkBlocks(expr, isWrapped(it));
				case EIf(econd, eif, eelse):
					if (!hasToken(IF)) return;
					checkBlocks(eif, isWrapped(econd));
					checkBlocks(eelse);
				case EWhile(econd, expr, _):
					if (!hasToken(WHILE)) return;
					checkBlocks(expr, isWrapped(econd));
				case ESwitch(expr, cases, edef):
					if (!hasToken(SWITCH)) return;
					var firstCase:Expr = edef;
					if (cases.length > 0) {
						firstCase = cases[0].values[0];
					}
					for (c in cases) {
						checkBlocks(c.expr, isListWrapped(c.values));
					}
					checkBlocks(edef);
					if (firstCase == null) {
						checkLinesBetween(e.pos.min, e.pos.max, isWrapped(expr), e.pos);
						return;
					}
					checkLinesBetween(expr.pos.max, firstCase.pos.min, isWrapped(expr), e.pos);
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

	function isFieldWrapped(field:Field):Bool {
		var pos1:Int = field.pos.min;
		var pos2:Int = pos1;
		switch (field.kind) {
			case FFun(f):
				if (f.expr == null) {
					return false;
				}
				pos2 = f.expr.pos.min;
			default:
				return false;
		}

		var functionDef:String = checker.file.content.substring(pos1, pos2);
		return (functionDef.indexOf('\n') >= 0) ||
		(functionDef.indexOf('\r') >= 0);
	}

	function isListWrapped(es:Array<Expr>):Bool {
		if (es == null) return false;
		if (es.length <= 0) return false;
		var posMin:Int = es[0].pos.min;
		var posMax:Int = es[es.length - 1].pos.max;
		return (checker.getLinePos(posMin).line != checker.getLinePos(posMax).line);
	}

	function isWrapped(e:Expr):Bool {
		if (e == null) return false;
		return (checker.getLinePos(e.pos.min).line != checker.getLinePos(e.pos.max).line);
	}

	function checkBlocks(e:Expr, wrapped:Bool = false) {
		if ((e == null) || (e.expr == null)) return;
		if (checker.file.content.charAt(e.pos.min) != "{") return;

		switch(e.expr) {
			case EBlock(_):
				var linePos:LinePos = checker.getLinePos(e.pos.min);
				var line:String = checker.lines[linePos.line];
				checkLeftCurly(line, wrapped, e.pos);
			default:
		}
	}

	function checkLinesBetween(min:Int, max:Int, wrapped:Bool = false, pos:Position) {
		if (isPosSuppressed(pos)) return;
		var bracePos:Int = checker.file.content.lastIndexOf("{", max);
		if (bracePos < 0 || bracePos < min) return;

		var lineNum:Int = checker.getLinePos(bracePos).line;
		var line:String = checker.lines[lineNum];
		checkLeftCurly(line, wrapped, pos);
	}

	function checkLeftCurly(line:String, wrapped:Bool = false, pos:Position) {
		var lineLength:Int = line.length;

		// must have at least one non whitespace character before curly
		// and only whitespace, }, /* + comment or // + comment after curly
		var curlyAtEOL:Bool = ~/^\s*\S.*\{\}?\s*(|\/\*.*|\/\/.*)$/.match(line);
		// must have only whitespace before curly
		var curlyOnNL:Bool = ~/^\s*\{\}?/.match(line);

		try {
			if (curlyAtEOL) {
				logErrorIf ((option == NL), 'Left curly should be on new line (only whitespace before curly)', pos);
				logErrorIf ((option == NLOW) && wrapped, 'Left curly should be on new line (previous expression is split over muliple lines)', pos);
				logErrorIf ((option != EOL) && (option != NLOW), 'Left curly unknown option ${option}', pos);
				return;
			}
			logErrorIf ((option == EOL), 'Left curly should be at EOL (only linebreak or comment after curly)', pos);
			logErrorIf ((!curlyOnNL), 'Left curly should be on new line (only whitespace before curly)', pos);
			logErrorIf ((option == NLOW) && !wrapped, 'Left curly should be at EOL (previous expression is not split over muliple lines)', pos);
			logErrorIf ((option != NL) && (option != NLOW), 'Left curly unknown option ${option}', pos);
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