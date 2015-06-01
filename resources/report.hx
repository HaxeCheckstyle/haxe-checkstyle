package ;

import haxe.CallStack;
import hxargs.Args;
import sys.io.FileOutput;
import sys.io.File;

class Report {

	var _staticAnalysisXML:Xml;
	var _reportFile:FileOutput;

	var _path:String;

	function run(args:Array<String>) {
		var files:Array<String> = [];
		var configPath:String = null;

		var argHandler = Args.generate([
			@doc("xml path") ["-p", "--path"] => function(loc:String) _path = loc,
			_ => function(arg:String) throw "Unknown command: " + arg
		]);

		if (args.length > 0) {
			argHandler.parse(args);
		}

		generateReport();
	}

	public function new() {
		_path = "./resources/static-analysis.xml";
	}
	
	function generateReport() {
		_staticAnalysisXML = Xml.parse(File.getContent(_path));
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

	@SuppressWarnings('checkstyle:Dynamic')
	public static function main() {
		var args;
		var cwd;
		var oldCwd = null;

		try {
			args = Sys.args();
			cwd = Sys.getCwd();
			if (Sys.getEnv("HAXELIB_RUN") != null) {
				cwd = args.pop();
				oldCwd = Sys.getCwd();
			}
			if (oldCwd != null) Sys.setCwd(cwd);

			var main = new Report();
			main.run(args);
		}
		catch(e:Dynamic) {
			trace(e);
			trace(CallStack.toString(CallStack.exceptionStack()));
		}
		if (oldCwd != null) Sys.setCwd(oldCwd);
	}
}