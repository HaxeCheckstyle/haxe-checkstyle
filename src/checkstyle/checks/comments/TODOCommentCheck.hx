package checkstyle.checks.comments;

import haxeparser.Data.Token;

@name("TODOComment")
@desc("A check for TODO/FIXME/HACK/XXX/BUG comments.")
class TODOCommentCheck extends Check {

	public var format:String;

	public function new() {
		super(LINE);
		format = "TODO|FIXME|HACK|XXX|BUG";
	}

	override function actualRun() {
		var re = new EReg(format, "");
		for (tk in checker.tokens) {
			switch (tk.tok) {
				case Comment(s) | CommentLine(s):
					if (re.match(s)) logPos("TODO comment:" + s, tk.pos);
				default:
			}
		}
	}
}