package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("FileLength")
@desc("Max number of lines per file (default 2000)")
class FileLengthCheck extends Check {

	public var severity:String = "WARNING";

	public var max:Int = 2000;

	override function _actualRun() {
		if (_checker.lines.length > max) log('Too many lines in file (> ${max})', _checker.lines.length, 1, Reflect.field(SeverityLevel, severity));
	}
}
