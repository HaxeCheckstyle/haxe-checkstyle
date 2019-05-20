package checkstyle.reporter;

class XMLReporter extends BaseReporter {
	var style:String;
	var messageCache:Map<String, Array<CheckMessage>>;

	/**
		Solution from mustache.js
		https://github.com/janl/mustache.js/blob/master/mustache.js#L49
	**/
	static var ENTITY_MAP:Map<String, String> = [
		"&" => "&amp;",
		"<" => "&lt;",
		">" => "&gt;",
		'"' => "&quot;",
		"'" => "&#39;",
		"/" => "&#x2F;"
	];

	static var ENTITY_RE:EReg = ~/[&<>"'\/]/g;

	public function new(numFiles:Int, checkCount:Int, usedCheckCount:Int, path:String, s:String, ns:Bool) {
		super(numFiles, checkCount, usedCheckCount, path, ns);
		messageCache = new Map<String, Array<CheckMessage>>();
		style = s;
	}

	override public function start() {
		var sb = new StringBuf();
		sb.add("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		if (style != "") {
			sb.add("<?xml-stylesheet type=\"text/xsl\" href=\"" + style + "\" ?>\n");
		}
		sb.add("<checkstyle version=\"5.7\">\n");
		if (file != null) report.add(sb.toString());

		super.start();
	}

	override public function finish() {
		var sb = new StringBuf();
		sb.add("</checkstyle>\n");
		if (file != null) report.add(sb.toString());

		super.finish();
	}

	function encode(s:String):String {
		return escapeXML(s);
	}

	override public function fileStart(f:CheckFile) {
		messageCache.set(f.name, []);
	}

	override public function fileFinish(f:CheckFile) {
		var sb = new StringBuf();
		sb.add("\t<file name=\"");
		sb.add(encode(f.name));
		sb.add("\">\n");
		var messages:Array<CheckMessage> = messageCache.get(f.name);
		for (m in messages) sb.add(formatMessage(m));
		messageCache.remove(f.name);
		sb.add("\t</file>\n");
		if (file != null) report.add(sb.toString());
	}

	static function replace(str:String, re:EReg):String {
		return re.map(str, function(re):String {
			return ENTITY_MAP[re.matched(0)];
		});
	}

	static function escapeXML(string:String):String {
		return replace(string, ENTITY_RE);
	}

	override public function addMessage(m:CheckMessage) {
		if (!messageCache.exists(m.fileName)) messageCache.set(m.fileName, [m]);
		else messageCache.get(m.fileName).push(m);
	}

	function formatMessage(m:CheckMessage):String {
		var sb:StringBuf = new StringBuf();

		sb.add("\t\t<error line=\"");
		sb.add(m.startLine);
		sb.add("\"");
		if (m.startColumn >= 0) {
			sb.add(" column=\"");
			sb.add(m.startColumn);
			sb.add("\"");
		}
		sb.add(" severity=\"");
		sb.add(BaseReporter.severityString(m.severity));
		sb.add("\"");
		sb.add(" message=\"");
		sb.add(encode(m.moduleName) + " - " + encode(m.message));
		sb.add("\"");
		sb.add(" source=\"");
		sb.add(encode(m.fileName));
		sb.add("\"/>\n");

		switch (m.severity) {
			case ERROR:
				errors++;
			case WARNING:
				warnings++;
			case INFO:
				infos++;
			default:
		}

		Sys.print(applyColour(getMessage(m).toString(), m.severity));

		return sb.toString();
	}
}