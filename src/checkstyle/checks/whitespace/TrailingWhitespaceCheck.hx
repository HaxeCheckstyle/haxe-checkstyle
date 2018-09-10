package checkstyle.checks.whitespace;

/**
	Checks if there are any trailing white spaces.
**/
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
			var ranges = getRanges(line);
			var endTextRange = ranges.filter(function(r):Bool return r.type == TEXT && r.end == line.length)[0];
			if (endTextRange == null) continue;
			var endText = line.substring(endTextRange.start, endTextRange.end);

			if (re.match(endText)) log("Trailing whitespace", i + 1, line.length, i + 1, line.length);
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "severity",
				values: ["INFO"]
			}]
		}];
	}
}