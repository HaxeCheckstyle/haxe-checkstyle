package checkstyle;

import checkstyle.ChecksInfo;
import checkstyle.checks.Check;
import checkstyle.reporter.ExitCodeReporter;
import checkstyle.reporter.IReporter;
import checkstyle.reporter.JSONReporter;
import checkstyle.reporter.Reporter;
import checkstyle.reporter.XMLReporter;
import haxe.CallStack;
import haxe.Json;
import hxargs.Args;
import sys.FileSystem;
import sys.io.File;

class Main {
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

			var main = new Main();
			main.run(args);

			if (REPORT && REPORT_TYPE == "xml") {
				var reporter = new Report();
				reporter.generateReport(XML_PATH);
			}
		}
		catch (e:Dynamic) {
			trace(e);
			trace(CallStack.toString(CallStack.exceptionStack()));
		}
		if (oldCwd != null) Sys.setCwd(oldCwd);
		Sys.exit(exitCode);
	}

	var reporter:IReporter;
	var info:ChecksInfo;
	var checker:Checker;

	static var REPORT:Bool = false;
	static var REPORT_TYPE:String = "xml";
	static var XML_PATH:String = "check-style-report.xml";
	static var JSON_PATH:String = "check-style-report.json";
	static var STYLE:String = "";
	static var EXIT_CODE:Bool = false;
	static var exitCode:Int;

	function new() {
		reporter = new Reporter();
		info = new ChecksInfo();
		checker = new Checker();
		exitCode = 0;
	}

	@SuppressWarnings(['checkstyle:Dynamic', 'checkstyle:MethodLength'])
	function run(args:Array<String>) {
		var files:Array<String> = [];
		var configPath:String = null;

		var argHandler = Args.generate([
			@doc("Set reporter path") ["-p", "--path"] => function(loc:String) {
				XML_PATH = loc;
				JSON_PATH = loc;
			},
			@doc("Set reporter style (XSLT)") ["-x", "--xslt"] => function(x:String) STYLE = x,
			@doc("Set reporter (xml, json or text)") ["-r", "--reporter"] => function(reporterName:String) REPORT_TYPE = reporterName,
			@doc("Set config (.json) file") ["-c", "--config"] => function(cpath:String) configPath = cpath,
			@doc("List all available checks") ["--list-checks"] => function() listChecks(),
			@doc("List all available reporters") ["--list-reporters"] => function() listReporters(),
			@doc("Show report") ["-report"] => function() REPORT = true,
			@doc("Return number of failed checks in exitcode") ["-exitcode"] => function() EXIT_CODE = true,
			@doc("Set source folder to process") ["-s", "--source"] => function(sourcePath:String) traverse(sourcePath, files),
			_ => function(arg:String) throw "Unknown command: " + arg
		]);

		if (args.length == 0) {
			Sys.println(argHandler.getDoc());
			Sys.exit(0);
		}
		argHandler.parse(args);

		var toProcess:Array<LintFile> = [];
		for (file in files) {
			var code = File.getContent(file);
			toProcess.push({name:file, content:code});
		}

		if (configPath == null) addAllChecks();
		else {
			var configText = File.getContent(configPath);
			var config = Json.parse(configText);
			var defaultSeverity = config.defaultSeverity;
			var checks:Array<Dynamic> = config.checks;
			for (checkConf in checks) {
				var check:Check = cast info.build(checkConf.type);
				if (check == null) continue;
				if (checkConf.props != null) {
					var props = Reflect.fields(checkConf.props);
					for (prop in props) {
						var val = Reflect.field(checkConf.props, prop);
						Reflect.setField(check, prop, val);
					}
					if (defaultSeverity != null && props.indexOf("severity") < 0) {
						check.severity = defaultSeverity;
					}
				}
				checker.addCheck(check);
			}
		}
		checker.addReporter(createReporter());
		if (EXIT_CODE) checker.addReporter(new ExitCodeReporter());
		checker.process(toProcess);
	}

	function addAllChecks() {
		for (check in info.checks()) checker.addCheck(info.build(check.name));
	}

	function listChecks() {
		for (check in info.checks()) Sys.println('${check.name}: ${check.description}');
	}

	static function createReporter():IReporter {
		return switch(REPORT_TYPE) {
			case "xml": new XMLReporter(XML_PATH, STYLE);
			case "json": new JSONReporter(JSON_PATH);
			case "text": new Reporter();
			default: throw "Unknown reporter";
		}
	}

	static function listReporters() {
		Sys.println("xml - Checkstyle XML reporter (default)");
		Sys.println("json - JSON reporter");
		Sys.println("text - Text reporter");
		Sys.exit(0);
	}

	static function pathJoin(s:String, t:String):String {
		return s + "/" + t;
	}

	static function traverse(node:String, files:Array<String>) {
		if (FileSystem.isDirectory(node)) {
			var nodes = FileSystem.readDirectory(node);
			for (child in nodes) traverse(pathJoin(node, child), files);
		}
		else if (~/(.hx)$/i.match(node)) files.push(node);
	}

	public static function setExitCode(newExitCode:Int) {
		exitCode = newExitCode;
	}
}