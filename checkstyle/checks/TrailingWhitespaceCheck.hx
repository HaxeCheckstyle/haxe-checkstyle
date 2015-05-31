package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("TrailingWhitespace")
@desc("Checks if there are any trailing white spaces")
class TrailingWhitespaceCheck extends Check {

	override function actualRun() {
		var re = ~/\S\s+$/;
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (re.match(line)) log('Trailing whitespace', i + 1, line.length, Reflect.field(SeverityLevel, severity));
		}
	}
}