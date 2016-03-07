package checkstyle;

import checkstyle.ChecksInfo;
import checkstyle.Config;
import checkstyle.LintMessage.SeverityLevel;
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

	static var DEFAULT_CONFIG:String = "checkstyle.json";
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

	function run(args:Array<String>) {
		var files:Array<String> = [];
		var configPath:String = null;

		var argHandler = Args.generate([
			@doc("Set source folder to process (multiple allowed)") ["-s", "--source"] => function(path:String) traverse(path, files),
			@doc("Set config file (default: checkstyle.json)") ["-c", "--config"] => function(path:String) configPath = path,
			@doc("Set reporter (xml, json or text, default: text)") ["-r", "--reporter"] => function(name:String) REPORT_TYPE = name,
			@doc("Set reporter output path") ["-p", "--path"] => function(path:String) {
				XML_PATH = path;
				JSON_PATH = path;
				TEXT_PATH = path;
			},
			@doc("Set reporter style (XSLT)") ["-x", "--xslt"] => function(style:String) STYLE = style,
			@doc("Show percentage progress") ["-progress"] => function() SHOW_PROGRESS = true,
			@doc("Return number of failed checks in exitcode") ["-exitcode"] => function() EXIT_CODE = true,
			@doc("List all available checks and exit") ["--list-checks"] => function() listChecks(),
			@doc("List all available reporters and exit") ["--list-reporters"] => function() listReporters(),
			@doc("Generate a default config and exit") ["--default-config"] => function(path) generateDefaultConfig(path),
			@doc("Show report [DEPRECATED]") ["-report"] => function() {},
			_ => function(arg:String) failWith("Unknown command: " + arg)
		]);

		if (args.length == 0) {
			Sys.println(argHandler.getDoc());
			Sys.exit(0);
		}
		argHandler.parse(args);

		var i:Int = 0;
		var toProcess:Array<LintFile> = [for (file in files) {name:file, content:null, index:i++}];

		if (configPath == null && FileSystem.exists(DEFAULT_CONFIG) && !FileSystem.isDirectory(DEFAULT_CONFIG)) {
			configPath = DEFAULT_CONFIG;
		}

		if (configPath == null) addAllChecks();
		else loadConfig(configPath);
		checker.addReporter(createReporter(files.length));
		if (SHOW_PROGRESS) checker.addReporter(new ProgressReporter(files.length));
		if (EXIT_CODE) checker.addReporter(new ExitCodeReporter());
		checker.process(toProcess);
	}

	function loadConfig(configPath:String) {
		var config:Config = Json.parse(File.getContent(configPath));
		verifyAllowedFields(config, ["checks", "defaultSeverity"], "Config");

		for (checkConf in config.checks) {
			var check = getCheck(checkConf);
			setCheckProperties(check, checkConf, config.defaultSeverity);
		}
	}

	function getCheck(checkConf:CheckConfig):Check {
		var check:Check = info.build(checkConf.type);
		if (check == null) failWith('Unknown check \'${checkConf.type}\'');
		checker.addCheck(check);
		return check;
	}

	function setCheckProperties(check:Check, checkConf:CheckConfig, defaultSeverity:SeverityLevel) {
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
		for (check in getSortedCheckInfos()) {
			if (!check.isAlias) checker.addCheck(info.build(check.name));
		}
	}

	function getSortedCheckInfos():Array<CheckInfo> {
		var checks:Array<CheckInfo> = [for (check in info.checks()) check];
		checks.sort(function(c1:CheckInfo, c2:CheckInfo):Int return (c1.name < c2.name) ? -1 : 1);
		return checks;
	}

	function listChecks() {
		for (check in getSortedCheckInfos()) {
			Sys.println(check.name + ":");
			Sys.println("  " + check.description + "\n");
		}
		Sys.exit(0);
	}

	function createReporter(numFiles:Int):IReporter {
		return switch (REPORT_TYPE) {
			case "xml": new XMLReporter(numFiles, XML_PATH, STYLE);
			case "json": new JSONReporter(numFiles, JSON_PATH);
			case "text": new TextReporter(numFiles, TEXT_PATH);
			default: failWith('Unknown reporter: $REPORT_TYPE'); null;
		}
	}

	function listReporters() {
		Sys.println("text - Text reporter (default)");
		Sys.println("xml - XML reporter");
		Sys.println("json - JSON reporter");
		Sys.exit(0);
	}

	function generateDefaultConfig(path) {
		addAllChecks();

		var config:Config = {
			defaultSeverity: SeverityLevel.INFO,
			checks: []
		};
		for (check in checker.checks) {
			var checkConfig:CheckConfig = {
				type: check.getModuleName(),
				props: {
					severity: SeverityLevel.IGNORE
				}
			};
			for (prop in Reflect.fields(check)) {
				if (prop == "moduleName" || prop == "severity") continue;
				Reflect.setField(checkConfig.props, prop, Reflect.field(check, prop));
			}
			config.checks.push(checkConfig);
		}

		var file = File.write(path, false);
		file.writeString(Json.stringify(config, null, "\t"));
		file.close();
		Sys.exit(0);
	}

	function pathJoin(s:String, t:String):String {
		return s + "/" + t;
	}

	function traverse(node:String, files:Array<String>) {
		if (FileSystem.isDirectory(node)) {
			var nodes = FileSystem.readDirectory(node);
			for (child in nodes) traverse(pathJoin(node, child), files);
		}
		else if (~/(.hx)$/i.match(node)) files.push(node);
	}

	function failWith(message:String) {
		Sys.stderr().writeString(message + "\n");
		Sys.exit(1);
	}

	public static function setExitCode(newExitCode:Int) {
		exitCode = newExitCode;
	}
}