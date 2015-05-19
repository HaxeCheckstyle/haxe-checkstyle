package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("FileLength")
@desc("Max number of lines per file (default 1000)")
class FileLengthCheck extends Check {

	public var severity:String = "WARNING";

	public var maxLength:Int = 1000;

	override function _actualRun() {
		if (_checker.lines.length > maxLength) log('Too many lines in file (> ${maxLength})', _checker.lines.length, 1, Reflect.field(SeverityLevel, severity));
	}
}
