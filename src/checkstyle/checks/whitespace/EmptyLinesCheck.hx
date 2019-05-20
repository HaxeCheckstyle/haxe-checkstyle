package checkstyle.checks.whitespace;

/**
	Checks for consecutive empty lines (default is 1). Also have options to check empty line separators after package,
	single-line and multi-line comments and class/interface/abstract declarations.
**/
@name("EmptyLines")
@desc("Checks for consecutive empty lines (default is 1). Also have options to check empty line separators after package, single-line and multi-line comments and class/interface/abstract declarations.")
class EmptyLinesCheck extends LineCheckBase {
	/**
		number of empty lines to allow
	**/
	public var max:Int;

	/**
		allow empty lines after a single line comment
	**/
	public var allowEmptyLineAfterSingleLineComment:Bool;

	/**
		allow empty lines after a mutli line comment
	**/
	public var allowEmptyLineAfterMultiLineComment:Bool;

	/**
		require an empty line after package definition
	**/
	public var requireEmptyLineAfterPackage:Bool;

	/**
		require an empty line after class keyword
	**/
	public var requireEmptyLineAfterClass:Bool;

	/**
		require an empty line after interface keyword
	**/
	public var requireEmptyLineAfterInterface:Bool;

	/**
		require an empty line after abstract keyword
	**/
	public var requireEmptyLineAfterAbstract:Bool;

	public function new() {
		super();
		max = 1;
		allowEmptyLineAfterSingleLineComment = true;
		allowEmptyLineAfterMultiLineComment = true;
		requireEmptyLineAfterPackage = true;
		requireEmptyLineAfterClass = true;
		requireEmptyLineAfterInterface = true;
		requireEmptyLineAfterAbstract = true;
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var inGroup = false;
		var isLastLinePackage = false;
		var isLastLineClass = false;
		var isLastLineInterface = false;
		var isLastLineAbstract = false;
		var start = 0;
		var end = 0;

		for (i in 0...checker.lines.length) {
			var line = checker.lines[i];
			var ranges = getRanges(line);
			if (ranges.length == 1) {
				switch (ranges[0].type) {
					case TEXT:
					case COMMENT(isBlock):
						if (isBlock) continue;
					case STRING(isInterpolated):
						continue;
				}
			}

			if (~/^\s*$/.match(line)) {
				if (!inGroup) {
					inGroup = true;
					start = i;
				}
				end = i;

				if (!allowEmptyLineAfterSingleLineComment) checkComment(i, start, ~/^(\/\/).*$/);
				if (!allowEmptyLineAfterMultiLineComment) checkComment(i, start, ~/^^(\/\*).*|(\*\/)$/);
			}
			else {
				if (inGroup) {
					inGroup = false;
					if (end - start + 1 > max) logInfo(start);
				}
				if (requireEmptyLineAfterPackage && isLastLinePackage) {
					log("Empty line required after package declaration", i + 1, 0, i + 1, 0);
				}
				if (requireEmptyLineAfterClass && isLastLineClass) {
					log("Empty line required after class declaration", i + 1, 0, i + 1, 0);
				}
				if (requireEmptyLineAfterInterface && isLastLineInterface) {
					log("Empty line required after interface declaration", i + 1, 0, i + 1, 0);
				}
				if (requireEmptyLineAfterAbstract && isLastLineAbstract) {
					log("Empty line required after abstract declaration", i + 1, 0, i + 1, 0);
				}
			}

			isLastLinePackage = ~/^\s*package\s.*?;/.match(line);
			isLastLineClass = ~/^\s*class\s.*?\{/.match(line);
			isLastLineInterface = ~/^\s*interface\s.*?\{/.match(line);
			isLastLineAbstract = ~/^\s*abstract\s.*?\{/.match(line);
		}

		if (inGroup) {
			inGroup = false;
			if (end - start + 1 > max) logInfo(start);
		}
	}

	function checkComment(i, start, regex) {
		if (i > 0 && regex.match(checker.lines[i - 1].trim())) {
			log("Empty line not allowed after comment(s)", start + 1, 0, start + 1, 0);
		}
	}

	function logInfo(pos) {
		log('Too many consecutive empty lines (> ${max})', pos + 1, 0, pos + 1, 0);
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [{
				propertyName: "max",
				value: 1
			}],
			properties: [{
				propertyName: "allowEmptyLineAfterSingleLineComment",
				values: [false, true]
			}, {
				propertyName: "allowEmptyLineAfterMultiLineComment",
				values: [false, true]
			}, {
				propertyName: "requireEmptyLineAfterPackage",
				values: [true, false]
			}, {
				propertyName: "requireEmptyLineAfterClass",
				values: [true, false]
			}, {
				propertyName: "requireEmptyLineAfterInterface",
				values: [true, false]
			}, {
				propertyName: "requireEmptyLineAfterAbstract",
				values: [true, false]
			}]
		}];
	}
}