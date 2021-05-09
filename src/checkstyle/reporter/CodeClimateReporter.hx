package checkstyle.reporter;

import checkstyle.Message.MessageLocation;
import haxe.Json;

using StringTools;

class CodeClimateReporter extends BaseReporter {
	static inline var INFO:String = "info";
	static inline var NORMAL:String = "normal";
	static inline var CRITICAL:String = "critical";
	static inline var REMEDIATION_BASE:Int = 50000;

	override public function start() {}

	override public function finish() {}

	override public function addMessage(message:Message) {
		Sys.print(Json.stringify(createIssue(message, message)));
		Sys.stdout().writeByte(0);
		for (related in message.related) {
			Sys.print(Json.stringify(createIssue(message, related)));
			Sys.stdout().writeByte(0);
		}
	}

	function createIssue(message:Message, location:MessageLocation):Any {
		var file = ~/^\/code\//.replace(location.fileName, "");
		file = ~/\/\//.replace(file, "/");

		var issue = {
			type: "issue",
			check_name: message.moduleName,
			description: message.message.replace("\"", "`"),
			content: {
				body: message.desc
			},
			severity: getSeverity(message.severity),
			categories: message.categories,
			remediation_points: message.points * REMEDIATION_BASE,
			location: {
				path: file,
				positions: {
					begin: {
						line: location.range.start.line,
						column: location.range.start.column
					},
					end: {
						line: location.range.end.line,
						column: location.range.end.column
					}
				}
			}
		};

		return issue;
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