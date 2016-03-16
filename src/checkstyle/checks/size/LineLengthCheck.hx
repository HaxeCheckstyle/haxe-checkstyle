package checkstyle.checks.size;

@name("LineLength")
@desc("Checks for long lines. Long lines are hard to read.")
class LineLengthCheck extends Check {

	static var DEFAULT_MAX_LENGTH:Int = 160;

	public var max:Int;
	public var ignorePattern:String;

	public function new() {
		super(LINE);
		max = DEFAULT_MAX_LENGTH;
		ignorePattern = "^$";
		categories = [Category.COMPLEXITY, Category.CLARITY];
		points = 2;
	}

	override function actualRun() {
		var ignoreRE = new EReg(ignorePattern, "");
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (line.length > max) {
				if (ignoreRE.match(line) || isLineSuppressed(i)) continue;
				log('Too long line - ${line.length}, max length allowed is ${max}', i + 1, 0, line.length);
			}
		}
	}
}