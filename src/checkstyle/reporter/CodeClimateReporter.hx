package checkstyle.reporter;

import haxe.Json;

using StringTools;

class CodeClimateReporter extends BaseReporter {
	static inline var INFO:String = "info";
	static inline var NORMAL:String = "normal";
	static inline var CRITICAL:String = "critical";
	static inline var REMEDIATION_BASE:Int = 50000;

	override public function start() {}

	override public function finish() {}

	override public function addMessage(m:CheckMessage) {
		var file = ~/^\/code\//.replace(m.fileName, "");
		file = ~/\/\//.replace(file, "/");

		var issue = {
			type: "issue",
			check_name: m.moduleName,
			description: m.message.replace("\"", "`"),
			content: {
				body: m.desc
			},
			severity: getSeverity(m.severity),
			categories: m.categories,
			remediation_points: m.points * REMEDIATION_BASE,
			location: {
				path: file,
				positions: {
					begin: {
						line: m.startLine,
						column: m.startColumn
					},
					end: {
						line: m.endLine,
						column: m.endColumn
					}
				}
			}
		};

		Sys.print(Json.stringify(issue));
		Sys.stdout().writeByte(0);
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