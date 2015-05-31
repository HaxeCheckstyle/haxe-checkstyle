package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("LineLength")
@desc("Max line length (default 200)")
class LineLengthCheck extends Check {

	public var maxCharacters:Int;

	public function new() {
		super();
		maxCharacters = 200;
	}

	override function actualRun() {
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (line.length > maxCharacters) {
				if (isLineSuppressed(i)) continue;
				log('Too long line (> ${maxCharacters})', i + 1, 1, Reflect.field(SeverityLevel, severity));
			}
		}
	}
}
