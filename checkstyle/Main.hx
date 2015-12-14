package checkstyle;

import checkstyle.ChecksInfo;
import checkstyle.reporter.IReporter;
import hxargs.Args;
import haxe.Json;
import sys.FileSystem;
import checkstyle.reporter.XMLReporter;
import checkstyle.reporter.Reporter;
import haxe.CallStack;
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
				reporter.generateReport(PATH);
			}
		}
		catch(e:Dynamic) {
			trace(e);
			trace(CallStack.toString(CallStack.exceptionStack()));
		}
		if (oldCwd != null) Sys.setCwd(oldCwd);
	}

	var reporter:IReporter;
	var info:ChecksInfo;
	var checker:Checker;

	static var REPORT:Bool = false;
	static var REPORT_TYPE:String = "xml";
	static var PATH:String = "check-style-report.xml";
	static var STYLE:String = "";

	function new() {
		reporter = new Reporter();
		info = new ChecksInfo();
		checker = new Checker();
	}

	@SuppressWarnings('checkstyle:Dynamic')
	function run(args:Array<String>) {
		var files:Array<String> = [];
		var configPath:String = null;

		var argHandler = Args.generate([
			@doc("Set reporter path (.xml file)") ["-p", "--path"] => function(loc:String) PATH = loc,
			@doc("Set reporter style (XSLT)") ["-x", "--xslt"] => function(x:String) STYLE = x,
			@doc("Set reporter (xml or text)") ["-r", "--reporter"] => function(reporterName:String) REPORT_TYPE = reporterName,
			@doc("Set config (.json) file") ["-c", "--config"] => function(cpath:String) configPath = cpath,
			@doc("List all available checks") ["--list-checks"] => function() listChecks(),
			@doc("List all available reporters") ["--list-reporters"] => function() listReporters(),
			@doc("Show report") ["-report"] => function() REPORT = true,
			@doc("Set source folder to process") ["-s", "--source"] => function(sourcePath:String) traverse(sourcePath, files),
			_ => function(arg:String) throw "Unknown command: " + arg
		]);

		if (args.length == 0) {
			Sys.println(argHandler.getDoc());
			Sys.exit(0);
		}
		argHandler.parse(args);

		reporter = createReporter();

		var toProcess:Array<LintFile> = [];
		for (file in files){
			var code = File.getContent(file);
			toProcess.push({name:file, content:code});
		}

		if (configPath == null) addAllChecks();
		else {
			var configText = File.getContent(configPath);
			var config = Json.parse(configText);
			var checks:Array<Dynamic> = config.checks;
			for (checkConf in checks){
				var check = info.build(checkConf.type);
				if (checkConf.props != null){
					var props = Reflect.fields(checkConf.props);
					for (prop in props){
						var val = Reflect.field(checkConf.props, prop);
						Reflect.setField(check, prop, val);
					}
				}
				checker.addCheck(check);
			}
		}
		checker.addReporter(reporter);
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
			case "xml": new XMLReporter(PATH, STYLE);
			case "text": new Reporter();
			default: throw "Unknown reporter";
		}
	}

	static function listReporters() {
		Sys.println("xml - Checkstyle XML reporter (default)");
		Sys.println("text - Text reporter");
		Sys.exit(0);
	}

	static function pathJoin(s:String, t:String):String {
		return s + "/" + t;
	}

	static function traverse(node:String , files:Array<String>) {
		if (FileSystem.isDirectory(node)) {
			var nodes = FileSystem.readDirectory(node);
			for (child in nodes) traverse(pathJoin(node, child), files);
		}
		else if (node.substr(-3) == ".hx") files.push(node);
	}
}