package checkstyle;

import checkstyle.Report.Style;
import sys.io.File;

@:enum
@SuppressWarnings('checkstyle:MemberName')
abstract Style(Int) {
	var BOLD = 1;
	var RED = 91;
	var BLUE = 94;
	var MAGENTA = 95;
}

class Report {

	var staticAnalysisXML:Xml;

	public function new() {}

	@SuppressWarnings(['checkstyle:LineLength', 'checkstyle:MultipleStringLiterals'])
	public function generateReport(path:String) {
		staticAnalysisXML = Xml.parse(File.getContent(path));

		var errors = 0;
		var warnings = 0;
		var infos = 0;
		var total = 0;
		var fileName;
		for (node in staticAnalysisXML.firstElement().elementsNamed("file")) {
			var fileNode:Xml = node;
			fileName = fileNode.get("name").split("&#x2F;").join(".");
			if (fileNode.elementsNamed("error").hasNext()) Sys.println(styleText("CLASS: " + fileName, Style.BOLD));
			for (error in fileNode.elementsNamed("error")) {
				var errorNode:Xml = error;
				var line = errorNode.get("line");
				var message = StringTools.htmlUnescape(errorNode.get("message"));
				switch (errorNode.get("severity")) {
					case "error":
						errors++;
						printMessage(Style.RED, "Error", line, message);
					case "warning":
						warnings++;
						printMessage(Style.MAGENTA, "Warning", line, message);
					case "info":
						infos++;
						printMessage(Style.BLUE, "Info", line, message);
				}
				total++;
			}
		}

		Sys.println(
			styleText("\nTotal Issues: " + total + " (", Style.BOLD) +
			styleText("Errors: " + errors, Style.RED) +
			styleText(", ", Style.BOLD) +
			styleText("Warnings: " + warnings, Style.MAGENTA) +
			styleText(", ", Style.BOLD) +
			styleText("Infos: " + infos, Style.BLUE) +
			styleText(")", Style.BOLD));
	}

	function printMessage(style:Style, type:String, line:String, message:String) {
		Sys.println("\t" + styleText(Std.string(type + ": LINE - " + line + ": " + message), style));
	}

	function styleText(s:String, style:Style):String {
		return '\033[${style}m${s}\033[0m';
	}
}