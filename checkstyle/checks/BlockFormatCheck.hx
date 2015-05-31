package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;

@name("BlockFormat")
@desc("Checks empty blocks and first/last lines of a block")
class BlockFormatCheck extends Check {
	
	public var emptyBlockCheck:Bool;

	var firstLineRE:EReg;
	var lastLineRE:EReg;

	public function new() {
		super();
		emptyBlockCheck = true;
		firstLineRE = ~/\{[\/*]?\s*$/;
		lastLineRE = ~/^\s*\}[,;\/*]?/;
	}

	override function actualRun() {
		ExprUtils.walkFile(checker.ast, function(e) {
			switch(e.expr){
				case EBlock([]) | EObjectDecl([]):
					if (emptyBlockCheck && e.pos.max - e.pos.min > "{}".length)
						logPos("Empty block should be written as {}", e.pos, Reflect.field(SeverityLevel, severity));
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
}
