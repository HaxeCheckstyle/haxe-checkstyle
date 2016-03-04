package checkstyle;

import sys.io.File;

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
			if (fileNode.elementsNamed("error").hasNext()) Sys.println("\033[1mCLASS: " + fileName + "\033[0m");
			for (error in fileNode.elementsNamed("error")) {
				var errorNode:Xml = error;
				var line = errorNode.get("line");
				var message = StringTools.htmlUnescape(errorNode.get("message"));
				switch (errorNode.get("severity")) {
					case "error":
						errors++;
						printMessage(91, "Error", line, message);
					case "warning":
						warnings++;
						printMessage(95, "Warning", line, message);
					case "info":
						infos++;
						printMessage(94, "Info", line, message);
				}
				total++;
			}
		}

		Sys.println("\033[1m\nTotal Issues: " + total + " (\033[0m\033[91mErrors: " + errors + "\033[0m, \033[95mWarnings: " + warnings + "\033[0m, \033[94mInfos: " + infos + ")\n" + "\033[0m");
	}

	function printMessage(color:Int, type:String, line:String, message:String) {
		Sys.println("\t\033[" + color + "m" + type + ": LINE - " + line + ": " + message + "\033[0m");
	}
}