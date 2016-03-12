package checkstyle.checks.whitespace;

@name("EmptyLines")
@desc("Checks for consecutive empty lines")
class EmptyLinesCheck extends Check {

	public var max:Int;
	public var allowEmptyLineAfterSingleLineComment:Bool;
	public var allowEmptyLineAfterMultiLineComment:Bool;
	public var requireEmptyLineAfterPackage:Bool;
	public var requireEmptyLineAfterClass:Bool;
	public var requireEmptyLineAfterInterface:Bool;
	public var requireEmptyLineAfterAbstract:Bool;

	public function new() {
		super(LINE);
		max = 1;
		allowEmptyLineAfterSingleLineComment = true;
		allowEmptyLineAfterMultiLineComment = true;
		requireEmptyLineAfterPackage = true;
		requireEmptyLineAfterClass = true;
		requireEmptyLineAfterInterface = true;
		requireEmptyLineAfterAbstract = true;
	}

	override function actualRun() {
		var inGroup = false;
		var isLastLinePackage = false;
		var isLastLineClass = false;
		var isLastLineInterface = false;
		var isLastLineAbstract = false;
		var start = 0;
		var end = 0;
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
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
					log('Empty line required after package declaration', i + 1, 0);
				}
				if (requireEmptyLineAfterClass && isLastLineClass) {
					log('Empty line required after class declaration', i + 1, 0);
				}
				if (requireEmptyLineAfterInterface && isLastLineInterface) {
					log('Empty line required after interface declaration', i + 1, 0);
				}
				if (requireEmptyLineAfterAbstract && isLastLineAbstract) {
					log('Empty line required after abstract declaration', i + 1, 0);
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
		if (i > 0 && regex.match(StringTools.trim(checker.lines[i - 1]))) {
			log('Empty line not allowed after comment(s)', start, 0);
		}
	}

	function logInfo(pos) {
		log('Too many consecutive empty lines (> ${max})', pos, 0);
	}
}