package checkstyle.reporter;

import checkstyle.Message.MessageLocation;

class XMLReporter extends BaseReporter {
	var style:String;
	var files:Array<String>;

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
		style = s;
		files = [];
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
		for (file in files) {
			makeFileTag(sb, file);
		}

		sb.add("</checkstyle>\n");
		if (file != null) report.add(sb.toString());

		super.finish();
	}

	function makeFileTag(sb:StringBuf, file:String) {
		sb.add('\t<file name="${encode(file)}">\n');
		for (message in messages) {
			if (file == message.fileName) {
				sb.add(formatMessage(message, message));
				continue;
			}
			for (related in message.related) {
				if (related.fileName != file) {
					continue;
				}
				sb.add(formatMessage(message, related));
			}
		}
		sb.add("\t</file>\n");
	}

	function encode(s:String):String {
		return escapeXML(s);
	}

	override public function addFile(f:CheckFile) {
		files.push(f.name);
	}

	static function replace(str:String, re:EReg):String {
		return re.map(str, function(re):String {
			return ENTITY_MAP[re.matched(0)];
		});
	}

	static function escapeXML(string:String):String {
		return replace(string, ENTITY_RE);
	}

	function formatMessage(message:Message, location:MessageLocation):String {
		var sb:StringBuf = new StringBuf();

		sb.add("\t\t<error line=\"");
		sb.add(location.range.start.line);
		sb.add("\"");
		if (location.range.start.column >= 0) {
			sb.add(" column=\"");
			sb.add(location.range.start.column);
			sb.add("\"");
		}
		sb.add(" severity=\"");
		sb.add(BaseReporter.severityString(message.severity));
		sb.add("\"");
		sb.add(" message=\"");
		sb.add(encode(message.moduleName) + " - " + encode(message.message));
		sb.add("\"");
		sb.add(" source=\"");
		sb.add(encode(location.fileName));
		sb.add("\"/>\n");

		switch (message.severity) {
			case ERROR:
				errors++;
			case WARNING:
				warnings++;
			case INFO:
				infos++;
			default:
		}

		Sys.print(applyColour(getMessage(message).toString(), message.severity));

		return sb.toString();
	}
}