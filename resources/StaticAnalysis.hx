package ;

import sys.io.File;

class StaticAnalysis {

	var _staticAnalysisXML:Xml;

	public function new() {
		_staticAnalysisXML = Xml.parse(File.getContent("./resources/static-analysis.xml"));
		var errors = 0;
		var warnings = 0;
		var infos = 0;
		var total = 0;
		var fileName;
		for (node in _staticAnalysisXML.firstElement().elementsNamed("file")) {
			var fileNode:Xml = node;
			fileName = fileNode.get("name").split("&#x2F;").join(".");
			if(fileNode.elementsNamed("error").hasNext()) Sys.println("\033[1mCLASS: " + fileName + "\033[0m");
			for (error in fileNode.elementsNamed("error")) {
				var errorNode:Xml = error;
				switch (errorNode.get("severity")) {
					case "error":
						errors++;
						Sys.println("\t\033[91mError: LINE - " + errorNode.get("line") + ": " + StringTools.htmlUnescape(errorNode.get("message")) + "\033[0m");
					case "warning":
						warnings++;
						Sys.println("\t\033[95mWarning: LINE - " + errorNode.get("line") + ": " + StringTools.htmlUnescape(errorNode.get("message")) + "\033[0m");
					case "info":
						infos++;
						Sys.println("\t\033[94mInfo: LINE - " + errorNode.get("line") + ": " + StringTools.htmlUnescape(errorNode.get("message")) + "\033[0m");
				}
				total++;
			}
		}

		Sys.println("\033[1m\nTotal Issues: " + total + " (\033[0m\033[91mErrors: " + errors + "\033[0m, \033[95mWarnings: " + warnings + "\033[0m, \033[94mInfos: " + infos + ")\n" + "\033[0m");
	}

	static function main() {
		new StaticAnalysis();
	}
}