package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("TODOComment")
@desc("Checks if there are any TODO's left")
class TODOCommentCheck extends Check {

	override function actualRun() {
		var re = ~/TODO|FIXME/;
		for (tk in checker.tokens) {
			switch(tk.tok) {
				case Comment(s) | CommentLine(s):
					if (re.match(s)) logPos('TODO comment:' + s, tk.pos, Reflect.field(SeverityLevel, severity));
				default:
			}
		}
	}
}