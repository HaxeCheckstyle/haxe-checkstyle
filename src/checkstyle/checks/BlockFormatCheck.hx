package checkstyle.checks;

import haxe.macro.Expr;
import checkstyle.LintMessage.SeverityLevel;

@name("BlockFormat")
@desc("Checks empty blocks, object declarations and first/last lines of a block")
class BlockFormatCheck extends Check {

	var firstLineRE:EReg;
	var lastLineRE:EReg;

	// require comment in empty block / object decl
	public static inline var TEXT:String = "text";
	// empty block / object decl can be empty or have comments
	// if block has no comments, enforces {} notation
	public static inline var EMPTY:String = "empty";

	public var option:String;

	public function new() {
		super();
		// allow whitespace and comments after left curly
		// (trailing whitespace is handled in a separate check)
		firstLineRE = ~/\{\s*(\/\/.*|\/\*.*|)$/;
		lastLineRE = ~/^\s*\}[,;\/*]?/;
		option = EMPTY;
	}

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e) {
			if (isPosSuppressed(e.pos)) return;
			switch(e.expr){
				case EBlock([]) | EObjectDecl([]):
					checkEmptyBlock(e);
				case EBlock(_) | EObjectDecl(_):
					var lmin = checker.getLinePos(e.pos.min).line;
					var lmax = checker.getLinePos(e.pos.max).line;

					if (lmin != lmax) {
						if (!firstLineRE.match(checker.lines[lmin])) {
							logPos("First line of multiline block should contain only {", e.pos, Reflect.field(SeverityLevel, severity));
						}
						if (!lastLineRE.match(checker.lines[lmax])) {
							logPos("Last line of multiline block should contain only } and maybe , or ;", e.pos, Reflect.field(SeverityLevel, severity));
						}
					}
				default:
			}
		});
	}

	function checkEmptyBlock(e:Expr) {
		if ((e == null) || (e.expr == null)) return;

		var block:String = checker.file.content.substring(e.pos.min, e.pos.max);
		var containsOnlyWS:Bool = (~/\{\s+\}/m.match(block));
		var containsText:Bool = (~/\{\s*\S.*\S\s*\}/m.match(block));

		if (option == TEXT) {
			if (!containsText) {
				logPos("Empty block should contain a comment", e.pos, Reflect.field(SeverityLevel, severity));
			}
			return;
		}
		if (containsOnlyWS) {
			logPos("Empty block should be written as {}", e.pos, Reflect.field(SeverityLevel, severity));
		}
	}
}