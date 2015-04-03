package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("LineLength")
@desc("Max line length (default 120)")
class LineLengthCheck extends Check {

	public var severity:String = "WARNING";

	public var maxLines:Int = 120;

	override function actualRun() {
		for (i in 0 ... _checker.lines.length) {
			var line = _checker.lines[i];
			if (line.length > maxLines) log('Too long line (> ${maxLines})', i + 1, 1, Reflect.field(SeverityLevel, severity));
		}
	}
}