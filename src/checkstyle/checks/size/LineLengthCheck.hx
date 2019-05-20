package checkstyle.checks.size;

/**
	Checks for long lines. Long lines are hard to read.
**/
@name("LineLength")
@desc("Checks for long lines. Long lines are hard to read.")
class LineLengthCheck extends Check {
	static var DEFAULT_MAX_LENGTH:Int = 160;

	/**
		maximum number of characters per line (default: 160)
	**/
	public var max:Int;

	/**
		ignore lines matching regex
	**/
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
		for (i in 0...checker.lines.length) {
			var line = checker.lines[i];
			if (line.length > max) {
				if (ignoreRE.match(line) || isLineSuppressed(i)) continue;
				log('Line is longer than ${max} characters (found ${line.length})', i + 1, 0, i + 1, line.length);
			}
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "max",
				values: [for (i in 0...7) 80 + i * 20]
			}]
		}];
	}
}