package checkstyle.reporter;

import haxe.Json;
import sys.io.File;
import checkstyle.LintMessage.SeverityLevel;

class JSONReporter implements IReporter {

	var report:GlobalReport;
	var fileReport:FileReport;
	var path:String;

	public function new(path:String) {
		this.path = path;
	}

	public function start() {
		report = [];
	}

	public function finish() {}

	public function fileStart(f:LintFile) {
		fileReport = {
			fileName: f.name,
			messages: []
		};
		report.push(fileReport);
	}

	public function fileFinish(f:LintFile) {
		File.saveContent(path, Json.stringify(report));
	}

	public function addMessage(m:LintMessage) {
		var reportMessage:ReportMessage = {
			line: m.line,
			column: m.column,
			severity: severityString(m.severity),
			message: m.message
		};
		fileReport.messages.push(reportMessage);
	}

	static function severityString(s:SeverityLevel):String {
		switch(s) {
			case INFO: return "info";
			case WARNING: return "warning";
			case ERROR: return "error";
			case IGNORE:
		}
		return "info";
	}
}

typedef ReportMessage = {
	var line:Int;
	var column:Int;
	var severity:String;
	var message:String;
};

typedef FileReport = {
	var fileName:String;
	var messages:Array<ReportMessage>;
};

typedef GlobalReport = Array<FileReport>;