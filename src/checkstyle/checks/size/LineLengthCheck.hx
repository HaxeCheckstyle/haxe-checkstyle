package checkstyle.checks.size;

@name("LineLength")
@desc("Max line length (default 160)")
class LineLengthCheck extends Check {

	static var DEFAULT_MAX_LENGTH:Int = 160;

	public var max:Int;

	public function new() {
		super(LINE);
		max = DEFAULT_MAX_LENGTH;
	}

	override function actualRun() {
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (line.length > max) {
				if (isLineSuppressed(i)) continue;
				log('Too long line (> ${max})', i + 1, 0, line.length);
			}
		}
	}
}