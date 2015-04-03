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

	static var report_type:String = "default";
	static var path:String = "check-style-report.xml";
	static var style:String = "";

	function new() {
		reporter = new Reporter();
		info = new ChecksInfo();
		checker = new Checker();
	}

	function run(args:Array<String>) {
		var files:Array<String> = [];
		var _configPath:String = null;

		var argHandler = Args.generate([
		@doc("Set reporter path")
		["-p", "--path"] => function(loc:String) path = loc,
		@doc("Set reporter style (XSLT)")
		["-x", "--xslt"] => function(x:String) style = x,
		@doc("Set reporter")
		["-r", "--reporter"] => function(reporterName:String) report_type = reporterName,
		@doc("List all reporters")
		["--list-reporters"] => function() listReporters(),
		@doc("Set config file")
		["-c", "--config"] => function(configPath:String) _configPath = configPath,
		@doc("List all checks")
		["--list-checks"] => function() listChecks(),
		@doc("Set sources to process")
		["-s", "--source"] => function(sourcePath:String) traverse(sourcePath,files),
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
			toProcess.push({name:file,content:code});
		}

		if (_configPath == null) addAllChecks();
		else {
			var configText = File.getContent(_configPath);
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

	function addAllChecks():Void {
		for (check in info.checks()) checker.addCheck(info.build(check.name));
	}

	function listChecks():Void {
		for (check in info.checks()) Sys.println('${check.name}: ${check.description}');
	}

	static function listReporters():Void {
		Sys.println("default - Default reporter");
		Sys.println("xml - Checkstyle-like XML reporter");
		Sys.exit(0);
	}

	static function createReporter():IReporter {
		return switch(report_type) {
			case "xml": new XMLReporter(path, style);
			case "default": new Reporter();
			default: throw "Unknown reporter";
		}
	}

	private static function pathJoin(s:String, t:String):String {
		return s + "/" + t;
	}

	private static function traverse(node:String , files:Array<String>) {
		if (FileSystem.isDirectory(node)) {
			var nodes = FileSystem.readDirectory(node);
			for (child in nodes) traverse(pathJoin(node,child), files);
		}
		else if (node.substr(-3) == ".hx") files.push(node);
	}
}