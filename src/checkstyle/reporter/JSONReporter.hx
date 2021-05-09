package checkstyle.reporter;

import checkstyle.Message.MessageLocation;
import haxe.Json;

class JSONReporter extends BaseReporter {
	var files:Array<String>;

	override public function start() {
		super.start();
	}

	override public function addFile(f:CheckFile) {
		files.push(f.name);
	}

	override public function finish() {
		var jsonReport:GlobalReport = [];
		for (file in files) {
			var fileReport:FileReport = makeFileReport(file);
			jsonReport.push(fileReport);
		}

		if (file != null) report.add(Json.stringify(jsonReport));
		super.finish();
	}

	function makeFileReport(file:String):FileReport {
		var fileReport:FileReport = {
			fileName: file,
			messages: []
		};
		for (message in messages) {
			if (file == message.fileName) {
				fileReport.messages.push(makeReportMessage(message, message));
				continue;
			}
			for (related in message.related) {
				if (related.fileName != file) {
					continue;
				}
				fileReport.messages.push(makeReportMessage(message, related));
			}
		}
		return fileReport;
	}

	function makeReportMessage(message:Message, location:MessageLocation):ReportMessage {
		return {
			line: location.range.start.line,
			column: location.range.start.column,
			severity: BaseReporter.severityString(message.severity),
			message: message.message
		};
	}

	override public function addMessage(message:Message) {
		super.addMessage(message);
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