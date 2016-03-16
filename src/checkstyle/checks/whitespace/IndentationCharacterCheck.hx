package checkstyle.checks.whitespace;

@name("IndentationCharacter")
@desc("Checks indentation character (tab/space, default is tab).")
class IndentationCharacterCheck extends Check {

	public var character:IndentationCharacterCheckCharacter;
	public var ignorePattern:String;

	public function new() {
		super(LINE);
		character = TAB;
		ignorePattern = "^$";
	}

	override function actualRun() {
		var ignoreRE = new EReg(ignorePattern, "");
		var re = (character == TAB) ? ~/^\t*(\S.*| \*.*)?$/ : ~/^ *(\S.*)?$/;
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (ignoreRE.match(line) || isLineSuppressed(i)) continue;
			if (line.length > 0 && !re.match(line)) log('Wrong indentation character (should be ${character})', i + 1, 0);
		}
	}
}

@:enum
abstract IndentationCharacterCheckCharacter(String) {
	var TAB = "tab";
	var SPACE = "space";
}