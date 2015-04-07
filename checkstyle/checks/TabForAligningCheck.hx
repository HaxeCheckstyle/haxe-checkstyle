package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;

@name("TabForAligning")
@desc("Checks if there are any tabs in the middle of a line")
class TabForAligningCheck extends Check {

	public var severity:String = "WARNING";

	override function _actualRun() {
		var re = ~/^\s*\S[^\t]*\t/;
		for (i in 0 ... _checker.lines.length) {
			var line = _checker.lines[i];
			if (re.match(line) && line.indexOf("//") == -1) log("Tab after non-space character. Use space for aligning", i + 1, line.length, Reflect.field(SeverityLevel, severity));
		}
	}
}