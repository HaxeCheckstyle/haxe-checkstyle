package checkstyle.checks.whitespace;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("IndentationCharacter")
@desc("Checks indentation character (tab/space, default is tab)")
class IndentationCharacterCheck extends Check {

	public var character:String;

	public function new() {
		super();
		character = "tab";
	}

	override function actualRun() {
		var re;
		var tab = (character == "tab");
		if (tab) {
			re = ~/^\t*(\S.*| \*.*)?$/;
		}
		else {
			re = ~/^ *(\S.*)?$/;
		}
		for (i in 0 ... checker.lines.length) {
			var line = checker.lines[i];
			if (line.length > 0 && !re.match(line)) log('Wrong indentation character (${character})', i + 1, 0, null, Reflect.field(SeverityLevel, severity));
		}
	}
}