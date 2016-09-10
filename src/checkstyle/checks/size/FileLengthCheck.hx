package checkstyle.checks.size;

@name("FileLength")
@desc("Checks for long source files. If a source file becomes very long it is hard to understand. Therefore long classes should usually be refactored into several individual classes that focus on a specific task.")
class FileLengthCheck extends Check {

	static var DEFAULT_MAX_LENGTH:Int = 2000;

	public var max:Int;

	public function new() {
		super(LINE);
		max = DEFAULT_MAX_LENGTH;
		categories = [Category.COMPLEXITY, Category.CLARITY];
		points = 21;
	}

	override function actualRun() {
		for (td in checker.ast.decls) {
			switch (td.decl){
				case EClass(d): for (field in d.data) if (isCheckSuppressed(field)) return;
				default:
			}
		}
		if (checker.lines.length > max) log('File length is ${checker.lines.length} lines (max allowed is ${max})', checker.lines.length, 0);
	}
}