package checkstyle.reporter;

import haxe.Json;

class CodeClimateReporter extends BaseReporter {

	override public function start() {}

	override public function finish() {}

	override public function addMessage(m:LintMessage) {
		var issue = {
			type: "issue",
			check_name: m.moduleName,
			description: m.message,
			severity: getSeverity(m.severity),
			categories: m.categories,
			points: m.points,
			location:{
				path: m.fileName,
				positions: {
					begin: {
						line: m.line,
						column: m.startColumn
					},
					end: {
						line: m.line,
						column: m.endColumn
					}
				}
			}
		};

		Sys.print(Json.stringify(issue) + "\u0000");
	}

	function getSeverity(severity:String):String {
		return switch (severity) {
			case "INFO": "info";
			case "WARNING": "normal";
			case "ERROR": "critical";
			case "INFO": "info";
		}
	}
}