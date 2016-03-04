package checkstyle.checks.size;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("FileLength")
@desc("Max number of lines per file (default 2000)")
class FileLengthCheck extends Check {

	static var DEFAULT_MAX_LENGTH:Int = 2000;

	public var max:Int;

	public function new() {
		super();
		max = DEFAULT_MAX_LENGTH;
	}

	override function actualRun() {
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EClass(d): for (field in d.data) if (isCheckSuppressed (field)) return;
				default:
			}
		}
		if (checker.lines.length > max) log('Too many lines in file (> ${max})', checker.lines.length, 0, null, Reflect.field(SeverityLevel, severity));
	}
}