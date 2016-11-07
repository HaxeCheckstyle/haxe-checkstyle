package checkstyle.checks.whitespace;

import checkstyle.CheckMessage.SeverityLevel;

@name("IndentationCharacter")
@desc("Checks indentation character (tab/space, default is tab).")
class IndentationCharacterCheck extends LineCheckBase {

	public var character:IndentationCharacterCheckCharacter;
	public var ignorePattern:String;

	public function new() {
		super();
		severity = SeverityLevel.IGNORE;
		character = TAB;
		ignorePattern = "^$";
	}

	override function actualRun() {
		var ignoreRE = new EReg(ignorePattern, "");
		var re = (character == TAB) ? ~/^\t*(\S.*| \*.*)?$/ : ~/^ *(\S.*)?$/;
		for (i in 0...checker.lines.length) {
			var line = checker.lines[i];
			var ranges = getRanges(line);
			var startTextRange = ranges.filter(function(r):Bool return r.type == TEXT && r.start == 0)[0];
			if (startTextRange == null) continue;
			var startText = line.substring(startTextRange.start, startTextRange.end);

			if (ignoreRE.match(line) || isLineSuppressed(i)) continue;
			if (!re.match(startText)) log('Wrong indentation character (should be ${character})', i + 1, 0);
		}
	}
}

@:enum
abstract IndentationCharacterCheckCharacter(String) {
	var TAB = "tab";
	var SPACE = "space";
}