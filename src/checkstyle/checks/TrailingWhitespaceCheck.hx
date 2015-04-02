package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("TrailingWhitespace")
class TrailingWhitespaceCheck extends Check {

	public static inline var DESC:String = "Checks if there are any trailing white spaces";

	public function new() {
		super();
	}

	override function actualRun() {
		var re = ~/\S\s+$/;
		for (i in 0 ... _checker.lines.length) {
			var line = _checker.lines[i];
			if (re.match(line)) log('Trailing whitespace', i + 1, line.length, SeverityLevel.INFO);
		}
	}
}