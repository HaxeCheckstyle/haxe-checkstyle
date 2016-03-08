package checkstyle.checks;

import haxeparser.Data.Token;

@name("TODOComment")
@desc("Checks if there are any TODO's left")
class TODOCommentCheck extends Check {

	public function new() {
		super(LINE);
	}

	override function actualRun() {
		var re = ~/TODO|FIXME/;
		for (tk in checker.tokens) {
			switch (tk.tok) {
				case Comment(s) | CommentLine(s):
					if (re.match(s)) logPos('TODO comment:' + s, tk.pos);
				default:
			}
		}
	}
}