package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("LineLength")
@desc("Max line length (default 160)")
class LineLengthCheck extends Check {

	public var max:Int;

	public function new() {
		super();
		max = 160;
	}

	override function actualRun() {
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (line.length > max) {
				if (isLineSuppressed(i)) continue;
				log('Too long line (> ${max})', i + 1, 1, Reflect.field(SeverityLevel, severity));
			}
		}
	}
}