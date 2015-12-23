package checkstyle.checks.whitespace;

import checkstyle.LintMessage.SeverityLevel;

@name("EmptyLines")
@desc("Checks for consecutive empty lines (default 1)")
class EmptyLinesCheck extends Check {

	public var max:Int;

	public function new() {
		super();
		max = 1;
	}

	override function actualRun() {
		var re = ~/^\s*$/;
		var inGroup = false;
		var start = 0;
		var end = 0;
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (re.match(line)) {
				if (!inGroup) {
					inGroup = true;
					start = i;
				}
				end = i;
			}
			else {
				if (inGroup) {
					inGroup = false;
					if (end - start + 1 > max) logInfo(start);
				}
			}
		}

		if (inGroup) {
			inGroup = false;
			if (end - start + 1 > max) logInfo(start);
		}
	}

	function logInfo(pos) {
		log('Too many consecutive empty lines (> ${max})', pos, 0, Reflect.field(SeverityLevel, severity));
	}
}