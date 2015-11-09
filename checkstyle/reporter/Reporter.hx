package checkstyle.reporter;

import checkstyle.LintMessage.SeverityLevel;

class Reporter implements IReporter {

	public function new() {}

	static function severityString(s:SeverityLevel):String {
		return switch(s){
			case INFO: return "info";
			case WARNING: return "warning";
			case ERROR: return "error";
			case IGNORE: return "ignore";
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
		if (m.column > 0) {
			sb.add(':');
			sb.add(m.column);
		}
		sb.add(": ");
		sb.add(severityString(m.severity));
		sb.add(": ");
		sb.add(m.message);
		sb.add("\n");
		Sys.stdout().writeString(sb.toString());
	}
}