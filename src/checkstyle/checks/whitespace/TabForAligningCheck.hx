package checkstyle.checks.whitespace;

@name("TabForAligning")
@desc("Checks if there are any tabs in the middle of a line.")
class TabForAligningCheck extends LineCheckBase {

	public var ignorePattern:String;

	public function new() {
		super();
		severity = SeverityLevel.IGNORE;
		ignorePattern = "^$";
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var ignoreRE = new EReg(ignorePattern, "");
		for (i in 0...checker.lines.length) {
			var line = checker.lines[i];
			var ranges = getRanges(line);

			if (ignoreRE.match(line)) continue;

			for (range in ranges.filter(function(r):Bool return r.type == TEXT)) {
				var re = range.start == 0 ? ~/\S[ ]*\t/ : ~/\t/;
				var rangeText = line.substring(range.start, range.end);
				if (re.match(rangeText)) log("Tab after non-space character, use space for aligning", i + 1, line.length);
			}
		}
	}
}