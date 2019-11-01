package checkstyle.checks.size;

import checkstyle.checks.whitespace.ListOfEmptyLines;

/**
	Checks for long source files. If a source file becomes very long it is hard to understand.
	Therefore long classes should usually be refactored into several individual classes that focus on a specific task.
**/
@name("FileLength")
@desc("Checks for long source files. If a source file becomes very long it is hard to understand. Therefore long classes should usually be refactored into several individual classes that focus on a specific task.")
class FileLengthCheck extends Check {
	static var DEFAULT_MAX_LENGTH:Int = 1000;

	/**
		maximum number of lines permitted per file (default: 2000)
	**/
	public var max:Int;

	/**
		ignores or includes empty lines when counting total file length
	**/
	public var ignoreEmptyLines:Bool;

	public function new() {
		super(LINE);
		max = DEFAULT_MAX_LENGTH;
		ignoreEmptyLines = true;
		categories = [Category.COMPLEXITY, Category.CLARITY];
		points = 21;
	}

	override function actualRun() {
		if (checker.ast == null) return;

		for (td in checker.ast.decls) {
			switch (td.decl) {
				case EClass(d):
					for (field in d.data) if (isCheckSuppressed(field)) return;
				default:
			}
		}

		var count = checker.lines.length;
		if (ignoreEmptyLines) {
			var emptyLines:ListOfEmptyLines = ListOfEmptyLines.detectEmptyLines(checker);
			count -= emptyLines.lines.length;
		}
		if (count > max) {
			log('File length is ${checker.lines.length} lines (max allowed is ${max})', checker.lines.length, 0, checker.lines.length, 0);
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "max",
				values: [for (i in 0...10) 400 + i * 100]
			}]
		}];
	}
}