package checkstyle.checks.whitespace;

using checkstyle.utils.StringUtils;

@name("TabForAligning")
@desc("Checks if there are any tabs in the middle of a line.")
class TabForAligningCheck extends LineCheckBase {

	public var ignorePattern:String;

	public function new() {
		super();
		ignorePattern = "^$";
		categories = [Category.STYLE, Category.CLARITY];
	}

	override function actualRun() {
		var ignoreRE = new EReg(ignorePattern, "");
		var re = ~/^\s*\S[^\t]*\t/;
		for (i in 0...checker.lines.length) {
			var line = checker.lines[i];
			if (ignoreRE.match(line)) continue;
			if (isMultineString(line)) continue;
			if (re.match(line)) log("Tab after non-space character, use space for aligning", i + 1, line.length);
		}
	}
}