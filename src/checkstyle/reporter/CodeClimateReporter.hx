package checkstyle.reporter;

import checkstyle.CheckMessage.SeverityLevel;
import haxe.Json;

class CodeClimateReporter extends BaseReporter {

	static var INFO:String = "info";
	static var NORMAL:String = "normal";
	static var CRITICAL:String = "critical";
	static var REMEDIATION_BASE:Int = 50000;

	override public function start() {}

	override public function finish() {}

	override public function addMessage(m:CheckMessage) {
		var issue = {
			type: "issue",
			check_name: m.moduleName,
			description: m.message,
			severity: getSeverity(m.severity),
			categories: m.categories,
			remediation_points: m.points * REMEDIATION_BASE,
			location:{
				path: ~/^\/code\//.replace(m.fileName, ""),
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

	function getSeverity(severity:SeverityLevel):String {
		return switch (severity) {
			case "INFO": INFO;
			case "WARNING": NORMAL;
			case "ERROR": CRITICAL;
			default: INFO;
		}
	}
}