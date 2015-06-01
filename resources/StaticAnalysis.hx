package ;

import sys.io.FileOutput;
import sys.io.File;

class StaticAnalysis {

	var _staticAnalysisXML:Xml;
	var _reportFile:FileOutput;

	public function new() {
		_staticAnalysisXML = Xml.parse(File.getContent("./resources/static-analysis.xml"));
		_reportFile = File.write("CHECKS.md", false);
		_reportFile.writeString("###Report of default checks on CheckStyle library itself\n\n");
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
						_reportFile.writeString("`Error: LINE - " + errorNode.get("line") + ": " + StringTools.htmlUnescape(errorNode.get("message")) + "`\n\n");
					case "warning":
						warnings++;
						Sys.println("\t\033[95mWarning: LINE - " + errorNode.get("line") + ": " + StringTools.htmlUnescape(errorNode.get("message")) + "\033[0m");
						_reportFile.writeString("`Warning: LINE - " + errorNode.get("line") + ": " + StringTools.htmlUnescape(errorNode.get("message")) + "`\n\n");
					case "info":
						infos++;
						Sys.println("\t\033[94mInfo: LINE - " + errorNode.get("line") + ": " + StringTools.htmlUnescape(errorNode.get("message")) + "\033[0m");
						_reportFile.writeString("`Info: LINE - " + errorNode.get("line") + ": " + StringTools.htmlUnescape(errorNode.get("message")) + "`\n\n");
				}
				total++;
			}
		}

		Sys.println("\033[1m\nTotal Issues: " + total + " (\033[0m\033[91mErrors: " + errors + "\033[0m, \033[95mWarnings: " + warnings + "\033[0m, \033[94mInfos: " + infos + ")\n" + "\033[0m");

		_reportFile.writeString("`Total Issues: " + total + " (Errors: " + errors + " Warnings: " + warnings + " Infos: " + infos + ")`");
	}

	static function main() {
		new StaticAnalysis();
	}
}