package checkstyle.checks.whitespace;

import checkstyle.CheckMessage.SeverityLevel;

@name("TrailingWhitespace")
@desc("Checks if there are any trailing white spaces.")
class TrailingWhitespaceCheck extends LineCheckBase {

	public function new() {
		super();
		severity = SeverityLevel.IGNORE;
	}

	override function actualRun() {
		var re = ~/\s+$/;
		for (i in 0...checker.lines.length) {
			var line = checker.lines[i];
			if (isMultineString(line)) continue;
			if (re.match(line)) log("Trailing whitespace", i + 1, line.length);
		}
	}
}