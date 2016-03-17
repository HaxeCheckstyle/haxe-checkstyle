package checkstyle.checks.whitespace;

@ignore("base class line based whitespace checks")
class LineCheckBase extends Check {

	var quotesRE:EReg;
	var multilineStartRE:EReg;
	var escapeRE:EReg;
	var multilineStringStart:Bool;

	public function new() {
		super(LINE);
		quotesRE = ~/('|")/;
		multilineStartRE = null;
		escapeRE = null;
		multilineStringStart = false;
	}

	function isMultineString(line:String):Bool {
		if (!multilineStringStart && quotesRE.match(line)) {
			var matched = quotesRE.matched(0);
			var matchedRight = quotesRE.matchedRight();
			multilineStartRE = new EReg(matched, "");
			escapeRE = new EReg("\\" + matched, "");
			multilineStringStart = !multilineStartRE.match(matchedRight) && !escapeRE.match(matchedRight);
		}
		else if (multilineStringStart && multilineStartRE != null && multilineStartRE.match(line) && !escapeRE.match(line)) {
			multilineStringStart = false;
			multilineStartRE = null;
			escapeRE = null;
		}
		return multilineStringStart;
	}
}