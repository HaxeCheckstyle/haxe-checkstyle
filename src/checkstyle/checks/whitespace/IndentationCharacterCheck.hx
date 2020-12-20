package checkstyle.checks.whitespace;

/**
	Checks indentation character (tab/space, default is tab).
**/
@name("IndentationCharacter")
@desc("Checks indentation character (tab/space, default is tab).")
class IndentationCharacterCheck extends LineCheckBase {
	/**
		set indentation to
		- tab = tab
		- space = space
	**/
	public var character:IndentationCharacterCheckCharacter;

	/**
		ignore lines that match regex
	**/
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
			if (!re.match(startText)) log('Wrong indentation character (should be ${character})', i + 1, 0, i + 1, 0);
		}
	}

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "character",
				values: [SPACE, TAB]
			}]
		}];
	}
}

/**
	indentation with
	- tab = tabs
	- space = space
**/
enum abstract IndentationCharacterCheckCharacter(String) {
	var TAB = "tab";
	var SPACE = "space";
}