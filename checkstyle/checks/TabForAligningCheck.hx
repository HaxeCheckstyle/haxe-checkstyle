package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;

@name("TabForAligning")
@desc("Checks if there are any tabs in the middle of a line")
class TabForAligningCheck extends Check {

	override function actualRun() {
		var re = ~/^\s*\S[^\t]*\t/;
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (re.match(line) && line.indexOf("//") == -1) log("Tab after non-space character. Use space for aligning", i + 1, line.length, Reflect.field(SeverityLevel, severity));
		}
	}
}