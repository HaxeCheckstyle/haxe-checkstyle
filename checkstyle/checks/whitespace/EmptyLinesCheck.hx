package checkstyle.checks.whitespace;

import StringTools;
import checkstyle.LintMessage.SeverityLevel;

@name("EmptyLines")
@desc("Checks for consecutive empty lines")
class EmptyLinesCheck extends Check {

	public var max:Int;
	public var allowEmptyLineAfterComment:Bool;

	public function new() {
		super();
		max = 1;
		allowEmptyLineAfterComment = true;
	}

	override function actualRun() {
		var inGroup = false;
		var start = 0;
		var end = 0;
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (~/^\s*$/.match(line)) {
				if (!inGroup) {
					inGroup = true;
					start = i;
				}
				end = i;

				if (i > 0 && !allowEmptyLineAfterComment && ~/^(\/\/).*|^(\/\*).*|(\*\/)$/.match(StringTools.trim(checker.lines[i - 1]))) {
					log('Empty line not allowed after comment(s)', start, 0, null, Reflect.field(SeverityLevel, severity));
				}
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
		log('Too many consecutive empty lines (> ${max})', pos, 0, null, Reflect.field(SeverityLevel, severity));
	}
}