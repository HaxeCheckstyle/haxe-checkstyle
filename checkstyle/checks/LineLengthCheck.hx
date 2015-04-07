package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("LineLength")
@desc("Max line length (default 80)")
class LineLengthCheck extends Check {

	public var severity:String = "WARNING";

	public var maxCharacters:Int = 80;

	override function _actualRun() {
		for (i in 0 ... _checker.lines.length) {
			var line = _checker.lines[i];
			if (line.length > maxCharacters) log('Too long line (> ${maxCharacters})', i + 1, 1, Reflect.field(SeverityLevel, severity));
		}
	}
}