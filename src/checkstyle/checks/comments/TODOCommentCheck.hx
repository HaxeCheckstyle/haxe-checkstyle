package checkstyle.checks.comments;

/**
	A check for TODO/FIXME/HACK/XXX/BUG comments. The format can be customised by changing `format` property.
**/
@name("TODOComment")
@desc("A check for TODO/FIXME/HACK/XXX/BUG comments. The format can be customised by changing `format` property.")
class TODOCommentCheck extends Check {
	/**
		regex todo comment format, defaults to "^\\s*(TODO|FIXME|HACK|XXX|BUG)"
	**/
	public var format:String;

	public function new() {
		super(LINE);
		severity = SeverityLevel.IGNORE;
		format = "^\\s*(TODO|FIXME|HACK|XXX|BUG)";
		categories = [Category.BUG_RISK];
		points = 8;
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

	override public function detectableInstances():DetectableInstances {
		return [{
			fixed: [],
			properties: [{
				propertyName: "format",
				values: ["^\\s*(TODO|FIXME|HACK|XXX|BUG)"]
			}]
		}];
	}
}