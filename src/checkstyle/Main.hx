package checkstyle;

import checkstyle.ChecksInfo;
import checkstyle.checks.Check;
import checkstyle.reporter.ExitCodeReporter;
import checkstyle.reporter.IReporter;
import checkstyle.reporter.JSONReporter;
import checkstyle.reporter.ProgressReporter;
import checkstyle.reporter.TextReporter;
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
		}
		catch (e:Dynamic) {
			Sys.stderr().writeString(e + "\n");
			Sys.stderr().writeString(CallStack.toString(CallStack.exceptionStack()) + "\n");
		}
		if (oldCwd != null) Sys.setCwd(oldCwd);
		Sys.exit(exitCode);
	}

	var info:ChecksInfo;
	var checker:Checker;

	static var REPORT_TYPE:String = "text";
	static var XML_PATH:String = "check-style-report.xml";
	static var JSON_PATH:String = "check-style-report.json";
	static var TEXT_PATH:String = null;
	static var STYLE:String = "";
	static var SHOW_PROGRESS:Bool = false;
	static var EXIT_CODE:Bool = false;
	static var exitCode:Int;

	function new() {
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
				TEXT_PATH = loc;
			},
			@doc("Set reporter style (XSLT)") ["-x", "--xslt"] => function(x:String) STYLE = x,
			@doc("Set reporter (xml, json or text)") ["-r", "--reporter"] => function(reporterName:String) REPORT_TYPE = reporterName,
			@doc("Set config (.json) file") ["-c", "--config"] => function(cpath:String) configPath = cpath,
			@doc("List all available checks") ["--list-checks"] => function() listChecks(),
			@doc("List all available reporters") ["--list-reporters"] => function() listReporters(),
			@doc("Show report [DEPRECATED]") ["-report"] => function() {},
			@doc("Show progress") ["-progress"] => function() SHOW_PROGRESS = true,
			@doc("Return number of failed checks in exitcode") ["-exitcode"] => function() EXIT_CODE = true,
			@doc("Set source folder to process") ["-s", "--source"] => function(sourcePath:String) traverse(sourcePath, files),
			_ => function(arg:String) failWith("Unknown command: " + arg)
		]);

		if (args.length == 0) {
			Sys.println(argHandler.getDoc());
			Sys.exit(0);
		}
		argHandler.parse(args);

		var toProcess:Array<LintFile> = [];
		var i:Int = 0;
		for (file in files) {
			toProcess.push({name:file, content:null, index:i++});
		}

		if (configPath == null) addAllChecks();
		else {
			var configText = File.getContent(configPath);
			var config = Json.parse(configText);
			verifyAllowedFields(config, ["checks", "defaultSeverity"], "Config");
			var defaultSeverity = config.defaultSeverity;
			var checks:Array<Dynamic> = config.checks;
			for (checkConf in checks) createCheck(checkConf, defaultSeverity);
		}
		checker.addReporter(createReporter());
		if (SHOW_PROGRESS) checker.addReporter(new ProgressReporter(files.length));
		if (EXIT_CODE) checker.addReporter(new ExitCodeReporter());
		checker.process(toProcess);
	}

	@SuppressWarnings('checkstyle:Dynamic', 'checkstyle:AvoidInlineConditionals')
	function createCheck(checkConf:Dynamic, defaultSeverity:String) {
		var check:Check = cast info.build(checkConf.type);
		if (check == null) failWith('Unknown check \'${checkConf.type}\'');
		verifyAllowedFields(checkConf, ["type", "props"], check.getModuleName());

		var props = (checkConf.props == null) ? [] : Reflect.fields(checkConf.props);
		// use Type.getInstanceFields to make it work in c++ / profiler
		var checkFields:Array<String> = Type.getInstanceFields(Type.getClass(check));
		for (prop in props) {
			var val = Reflect.field(checkConf.props, prop);
			if (checkFields.indexOf(prop) < 0) {
				failWith('Check ${check.getModuleName()} has no property named \'$prop\'');
			}
			Reflect.setField(check, prop, val);
		}
		if (defaultSeverity != null && props.indexOf("severity") < 0) {
			check.severity = defaultSeverity;
		}
		checker.addCheck(check);
	}

	@SuppressWarnings('checkstyle:Dynamic')
	function verifyAllowedFields(object:Dynamic, allowedFields:Array<String>, messagePrefix:String) {
		for (field in Reflect.fields(object)) {
			if (allowedFields.indexOf(field) < 0) {
				failWith(messagePrefix + " has unknown field '" + field + "'");
			}
		}
	}

	function addAllChecks() {
		for (check in info.checks()) checker.addCheck(info.build(check.name));
	}

	function listChecks() {
		for (check in info.checks()) Sys.println('${check.name}: ${check.description}');
	}

	static function createReporter():IReporter {
		return switch (REPORT_TYPE) {
			case "xml": new XMLReporter(XML_PATH, STYLE);
			case "json": new JSONReporter(JSON_PATH);
			case "text": new TextReporter(TEXT_PATH);
			default: failWith('Unknown reporter: $REPORT_TYPE'); null;
		}
	}

	static function listReporters() {
		Sys.println("text - Text reporter (default)");
		Sys.println("xml - Checkstyle XML reporter");
		Sys.println("json - JSON reporter");
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

	static function failWith(message:String) {
		Sys.stderr().writeString(message + "\n");
		Sys.exit(1);
	}

	public static function setExitCode(newExitCode:Int) {
		exitCode = newExitCode;
	}
}