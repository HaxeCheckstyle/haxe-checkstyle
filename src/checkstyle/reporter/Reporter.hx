package checkstyle.reporter;

import checkstyle.LintMessage.SeverityLevel;
class Reporter implements IReporter{
	public function new(){

	}

	static function severityString(s:SeverityLevel):String{
		return switch(s){
		case INFO: return "info";
		case WARNING: return "warning";
		case ERROR: return "error";
		}
	}

	public function start():Void{}
	public function finish():Void{}
	public function fileStart(f:LintFile):Void{}
	public function fileFinish(f:LintFile):Void{}

	public function addMessage(m:LintMessage){
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
