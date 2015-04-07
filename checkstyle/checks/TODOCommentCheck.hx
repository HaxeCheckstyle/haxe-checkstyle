package checkstyle.checks;

import checkstyle.LintMessage.SeverityLevel;
import haxeparser.Data.Token;

@name("TODOComment")
@desc("Checks if there are any TODO's left")
class TODOCommentCheck extends Check {

	public var severity:String = "INFO";

	override function _actualRun() {
		var re = ~/TODO|FIXME/;
		for (tk in _checker.tokens) {
			switch tk.tok {
				case Comment(s) | CommentLine(s):
					var lp = _checker.getLinePos(tk.pos.min);
					if (re.match(s)) log('TODO comment:' + s, lp.line + 1, lp.ofs + 1, Reflect.field(SeverityLevel, severity));
				default:
			}
		}
	}
}