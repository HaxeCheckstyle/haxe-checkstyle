package checkstyle.reporter;

import checkstyle.LintMessage.SeverityLevel;
import sys.io.File;
import sys.io.FileOutput;

class TextReporter implements IReporter {

	var report:StringBuf;
	var file:FileOutput;

	public function new(path:String) {
		if (path != null) {
			file = File.write(path);
			report = new StringBuf();
		}
	}

	static function severityString(s:SeverityLevel):String {
		return switch (s){
			case INFO: return "Info";
			case WARNING: return "Warning";
			case ERROR: return "Error";
			case IGNORE: return "Ignore";
		}
	}

	public function start() {}

	public function finish() {
		if (file != null) {
			file.writeString(report.toString());
			file.close();
		}
	}

	public function fileStart(f:LintFile) {}

	public function fileFinish(f:LintFile) {}

	@SuppressWarnings('checkstyle:AvoidInlineConditionals')
	public function addMessage(m:LintMessage) {
		var sb:StringBuf = new StringBuf();
		sb.add(m.fileName);
		sb.add(':');
		sb.add(m.line);
		if (m.startColumn >= 0) {
			var isRange = m.startColumn != m.endColumn;
			sb.add(': character${isRange ? "s" : ""} ');
			sb.add(m.startColumn);
			if (isRange) {
				sb.add('-');
				sb.add(m.endColumn);
			}
			sb.add(' ');
		}
		sb.add(": ");
		sb.add(severityString(m.severity));
		sb.add(": ");
		sb.add(m.message);
		sb.add("\n");

		var output = (m.severity == ERROR || m.severity == WARNING) ? Sys.stderr() : Sys.stdout();
		var line = sb.toString();
		output.writeString(line);
		if (file != null) report.add(line);
	}
}