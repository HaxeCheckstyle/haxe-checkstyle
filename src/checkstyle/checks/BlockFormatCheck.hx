package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;

@name("BlockFormatCheck")
@desc("Checks empty blocks {} and first/lines of a block")
class BlockFormatCheck extends Check {

	public var severity:String = "INFO";

	var firstLineRE = ~/\{\s*$/;
	var lastLineRE = ~/^\s*\}[,;]?/;

	override function actualRun() {
		ExprUtils.walkFile(_checker.ast, function(e){
			switch(e.expr){
			case EBlock([]) | EObjectDecl([]):
				if (e.pos.max - e.pos.min > "{}".length)
					logPos("Empty block should be written as {}", e.pos, Reflect.field(SeverityLevel, severity));
			case EBlock(_) | EObjectDecl(_):
				var lmin =_checker.getLinePos(e.pos.min).line;
				var lmax =_checker.getLinePos(e.pos.max).line;
				if (lmin != lmax){
					if (! firstLineRE.match(_checker.lines[lmin])){
						logPos("First line of multiline block should contain only `{'", e.pos, Reflect.field(SeverityLevel, severity));
					}
					if (! lastLineRE.match(_checker.lines[lmax])){
						logPos("Last line of multiline block should contain only `}' and maybe `,' or `;'", e.pos, Reflect.field(SeverityLevel, severity));
					}
				}
			default:
			}
		});
	}
}
