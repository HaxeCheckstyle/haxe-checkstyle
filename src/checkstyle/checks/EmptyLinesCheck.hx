package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;

@name("EmptyLines")
class EmptyLinesCheck extends Check {

	public static inline var DESC:String = "Checks if there is more that 1 empty line";

	public function new(){
		super();
	}

	override function actualRun() {
		checkEmptyLinesGroup();
	}

	public var maxConsecutiveEmptyLines = 1;

	function checkEmptyLinesGroup(){
		var re = ~/^\s*$/;
		var inGroup = false;
		var start = 0;
		var end = 0;
		for (i in 0 ... _checker.lines.length){
			var line = _checker.lines[i];
			if (re.match(line)){
				if (! inGroup){
					inGroup = true;
					start = i;
				}
				end = i;
			}
			else {
				if (inGroup){
					inGroup = false;
					if (end - start + 1 > maxConsecutiveEmptyLines){
						log("Too many consecutive empty lines", start, 0, SeverityLevel.INFO);
					}
				}
			}
		}

		if (inGroup){
			inGroup = false;
			if (end - start + 1 > maxConsecutiveEmptyLines){
				log("Too many consecutive empty lines", start, 0, SeverityLevel.INFO);
			}
		}
	}
}