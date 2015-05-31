package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("FileLength")
@desc("Max number of lines per file (default 2000)")
class FileLengthCheck extends Check {

	public var max:Int;

	public function new() {
		super();
		max = 2000;
	}

	override function actualRun() {
		if (checker.lines.length > max) log('Too many lines in file (> ${max})', checker.lines.length, 1, Reflect.field(SeverityLevel, severity));
	}
}