package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("LineLength")
class LineLengthCheck extends Check {
	public function new() {
		super();
	}

	override function actualRun() {
		var length = 240;
		for (i in 0 ... _checker.lines.length) {
			var line = _checker.lines[i];
			if (line.length > length) log('Too long line', i + 1, 1, SeverityLevel.WARNING);
		}
	}
}