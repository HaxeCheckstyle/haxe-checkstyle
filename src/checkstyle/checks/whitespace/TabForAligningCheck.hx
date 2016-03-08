package checkstyle.checks.whitespace;

import checkstyle.LintMessage.SeverityLevel;

using checkstyle.utils.StringUtils;

@name("TabForAligning")
@desc("Checks if there are any tabs in the middle of a line")
class TabForAligningCheck extends Check {

	public function new() {
		super(LINE);
	}

	override function actualRun() {
		var re = ~/^\s*\S[^\t]*\t/;
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (re.match(line) && !line.contains("//")) {
				log("Tab after non-space character. Use space for aligning", i + 1, line.length);
			}
		}
	}
}