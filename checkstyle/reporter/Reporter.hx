package checkstyle.reporter;

import checkstyle.LintMessage.SeverityLevel;

class Reporter implements IReporter {

	public function new() {}

	static function severityString(s:SeverityLevel):String {
		return switch(s){
			case INFO: return "Info";
			case WARNING: return "Warning";
			case ERROR: return "Error";
			case IGNORE: return "Ignore";
		}
	}

	public function start() {}

	public function finish() {}

	public function fileStart(f:LintFile) {}

	public function fileFinish(f:LintFile) {}

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
		output.writeString(sb.toString());
	}
}