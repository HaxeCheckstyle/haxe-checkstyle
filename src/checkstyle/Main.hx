package checkstyle;

import checkstyle.ChecksInfo;
import checkstyle.checks.Check;
import checkstyle.config.CheckConfig;
import checkstyle.config.ConfigParser;
import checkstyle.config.ExcludeManager;
import checkstyle.detect.DetectCodingStyle;
import checkstyle.reporter.CodeClimateReporter;
import checkstyle.reporter.ExitCodeReporter;
import checkstyle.reporter.IReporter;
import checkstyle.reporter.JSONReporter;
import checkstyle.reporter.ProgressReporter;
import checkstyle.reporter.ReporterManager;
import checkstyle.reporter.TextReporter;
import checkstyle.reporter.XMLReporter;
import checkstyle.utils.ConfigUtils;
import haxe.CallStack;
import haxe.Json;
import haxe.io.Path;
import hxargs.Args;
import sys.FileSystem;
import sys.io.File;

class Main {
	static var DEFAULT_CONFIG:String = "checkstyle.json";
	static var DEFAULT_EXCLUDE_CONFIG:String = "checkstyle-exclude.json";
	static var REPORT_TYPE:String = "text";
	static var XML_PATH:String = "check-style-report.xml";
	static var JSON_PATH:String = "check-style-report.json";
	static var TEXT_PATH:String = null;
	static var STYLE:String = "";
	static var SHOW_PROGRESS:Bool = false;
	static var EXIT_CODE:Bool = false;
	static var NO_STYLE:Bool = false;
	static var CODE_CLIMATE_REPORTER:String = "codeclimate";
	static var SHOW_MISSING_CHECKS:Bool = false;
	static var exitCode:Int;

	var checker:Checker;
	var configPath:String;
	var excludePath:String;
	var disableThreads:Bool;
	var detectConfig:String;
	var configParser:ConfigParser;

	function new() {
		exitCode = 0;
		configPath = null;
		excludePath = null;
		detectConfig = null;
		configParser = new ConfigParser(failWith);
		checker = configParser.checker;
	}

	function run(args:Array<String>) {
		var argHandler = Args.generate([
			@doc("Set source path to process (multiple allowed)")
			["-s", "--source"] => function(path:String) configParser.paths.push(path),
			@doc("Set config file (default: checkstyle.json)")
			["-c", "--config"] => function(path:String) configPath = path,
			@doc("Set exclude file (default: checkstyle-exclude.json)")
			["-e", "--exclude"] => function(path:String) excludePath = path,
			@doc("Set reporter (xml, json or text, default: text)")
			["-r", "--reporter"] => function(name:String) REPORT_TYPE = name,
			@doc("Set reporter output path")
			["-p", "--path"] => function(path:String) {
				XML_PATH = path;
				JSON_PATH = path;
				TEXT_PATH = path;
			},
			@doc("Set reporter style (XSLT)")
			["-x", "--xslt"] => function(style:String) STYLE = style,
			@doc("Sets the number of checker threads")
			["--checkerthreads"] => function(num:Int) configParser.overrideCheckerThreads = num,
			@doc("Generate a default config and exit")
			["--default-config"] => function(path) generateDefaultConfig(path),
			@doc("Try to detect your coding style (experimental)")
			["--detect"] => function(path) detectCodingStyle(path),
			@doc("Return number of failed checks in exitcode")
			["--exitcode"] => function() EXIT_CODE = true,
			@doc("List all available checks and exit")
			["--list-checks"] => function() listChecks(),
			@doc("List all available reporters and exit")
			["--list-reporters"] => function() listReporters(),
			@doc("Omit styling in output summary")
			["--nostyle"] => function() NO_STYLE = true,
			@doc("Do not use checker threads")
			["--nothreads"] => function() disableThreads = true,
			@doc("Show percentage progress")
			["--progress"] => function() SHOW_PROGRESS = true,
			@doc("Show checks missing from active config")
			["--show-missing-checks"] => function() SHOW_MISSING_CHECKS = true,
			@doc("Adds error messages for files that checkstyle fails to parse")
			["--show-parser-errors"] => function() ReporterManager.SHOW_PARSE_ERRORS = true,
			_ => function(arg:String) failWith("Unknown command: " + arg)
		]);

		if (args.length == 0) {
			var version:String = CheckstyleVersion.getCheckstyleVersion();
			Sys.println('Haxe Checkstyle v${version}');
			Sys.println(argHandler.getDoc());
			Sys.exit(0);
		}
		argHandler.parse(args);

		if (REPORT_TYPE == CODE_CLIMATE_REPORTER) {
			var defaultConfig:CodeclimateConfig = Json.parse(File.getContent("/config.json"));
			if (defaultConfig.include_paths != null && defaultConfig.include_paths.length > 0) {
				for (s in defaultConfig.include_paths) {
					if (s != ".codeclimate.yml") configParser.paths.push("/code/" + s);
				}
			}
			else configParser.paths.push("/code");
			configParser.validateMode = RELAXED;

			if (defaultConfig.config != null) configPath = defaultConfig.config;
			if (defaultConfig.exclude != null) excludePath = defaultConfig.exclude;
			if (configParser.paths.length > 0) processArgs();
		}
		else processArgs();
	}

	function processArgs() {
		if (configPath == null && FileSystem.exists(DEFAULT_CONFIG) && !FileSystem.isDirectory(DEFAULT_CONFIG)) {
			configPath = DEFAULT_CONFIG;
		}
		if (excludePath == null && FileSystem.exists(DEFAULT_EXCLUDE_CONFIG) && !FileSystem.isDirectory(DEFAULT_EXCLUDE_CONFIG)) {
			excludePath = DEFAULT_EXCLUDE_CONFIG;
		}

		configParser.loadConfig(configPath);
		if (excludePath != null) configParser.loadExcludeConfig(excludePath);
		start();
	}

	function createReporter(numFiles:Int):IReporter {
		var totalChecks = configParser.getCheckCount();
		var checksUsed = configParser.getUsedCheckCount();
		return switch (REPORT_TYPE) {
			case "xml":
				new XMLReporter(numFiles, totalChecks, checksUsed, XML_PATH, STYLE, NO_STYLE);
			case "json":
				new JSONReporter(numFiles, totalChecks, checksUsed, JSON_PATH, NO_STYLE);
			case "text":
				new TextReporter(numFiles, totalChecks, checksUsed, TEXT_PATH, NO_STYLE);
			case "codeclimate":
				new CodeClimateReporter(numFiles, totalChecks, checksUsed, null, NO_STYLE);
			default:
				failWith('Unknown reporter: $REPORT_TYPE');
				null;
		}
	}

	function listChecks() {
		var count = 0;
		var maxLength:Int = 0;
		var checkList:Array<CheckInfo> = configParser.getSortedCheckInfos();
		for (check in checkList) {
			if (check.name.length > maxLength) {
				maxLength = check.name.length;
			}
		}

		for (check in checkList) {
			Sys.println(check.name.rpad(" ", maxLength + 2) + "- " + check.description);
			if (~/\[DEPRECATED/.match(check.description)) continue;
			count++;
		}
		Sys.println("Total: " + count + " checks");
		Sys.exit(0);
	}

	function listReporters() {
		Sys.println("text - Text reporter (default)");
		Sys.println("xml - XML reporter");
		Sys.println("json - JSON reporter");
		Sys.exit(0);
	}

	function generateDefaultConfig(path) {
		configParser.addAllChecks();
		ConfigUtils.saveConfig(checker, path);
		Sys.exit(0);
	}

	function detectCodingStyle(path:String) {
		var checks:Array<Check> = [];
		for (checkInfo in configParser.info.checks()) {
			if (checkInfo.isAlias) continue;
			var check:Check = configParser.info.build(checkInfo.name);
			checks.push(check);
		}
		var detectedChecks:Array<CheckConfig> = DetectCodingStyle.detectCodingStyle(checks, buildFileList());
		if (detectedChecks.length > 0) ConfigUtils.saveCheckConfigList(detectedChecks, path);
		Sys.exit(0);
	}

	function start() {
		if (SHOW_MISSING_CHECKS) {
			showMissingChecks();
			Sys.exit(0);
		}

		var toProcess:Array<CheckFile> = buildFileList();

		ReporterManager.INSTANCE.addReporter(createReporter(toProcess.length));
		if (SHOW_PROGRESS) ReporterManager.INSTANCE.addReporter(new ProgressReporter(toProcess.length));
		if (EXIT_CODE) ReporterManager.INSTANCE.addReporter(new ExitCodeReporter());

		#if (neko || cpp)
		if (disableThreads) {
			checker.process(toProcess);
		}
		else {
			ReporterManager.INSTANCE.start();
			var parserQueue:ParserQueue = new ParserQueue(toProcess, checker);
			var preParseCount:Int = configParser.numberOfCheckerThreads * 3;
			if (preParseCount < 15) preParseCount = 15;
			parserQueue.start(preParseCount);
			var checkerPool:CheckerPool = new CheckerPool(parserQueue, checker);
			checkerPool.start(configParser.numberOfCheckerThreads);

			while (!checkerPool.isFinished()) Sys.sleep(0.1);
			ReporterManager.INSTANCE.finish();
		}
		#else
		checker.process(toProcess);
		#end
	}

	function buildFileList():Array<CheckFile> {
		var files:Array<String> = [];
		for (path in configParser.paths) traverse(path, files);
		files.sortStrings();

		var i:Int = 0;
		return [for (file in files) {name: file, content: null, index: i++}];
	}

	function traverse(path:String, files:Array<String>) {
		try {
			if (FileSystem.isDirectory(path) && !ExcludeManager.isExcludedFromAll(path)) {
				var nodes = FileSystem.readDirectory(path);
				for (child in nodes) traverse(Path.join([path, child]), files);
			}
			else if (~/(.hx)$/i.match(path) && !ExcludeManager.isExcludedFromAll(path)) {
				files.push(path);
			}
		}
		catch (e:Any) {
			Sys.println("\nPath " + path + " not found.");
		}
	}

	function failWith(message:String) {
		if (REPORT_TYPE == CODE_CLIMATE_REPORTER) return;
		Sys.stderr().writeString(message + "\n");
		Sys.exit(1);
	}

	public static function setExitCode(newExitCode:Int) {
		exitCode = newExitCode;
	}

	function showMissingChecks() {
		var configuredChecks = [];
		var missingChecks = [];

		for (check in checker.checks) {
			configuredChecks.push(check.getModuleName());
		}
		for (check in configParser.info.checks()) {
			if (configuredChecks.indexOf(check.name) >= 0) continue;
			if (~/\[DEPRECATED/.match(check.description)) continue;
			missingChecks.push(check);
		}
		if (missingChecks.length <= 0) {
			Sys.println("You have no checks missing from your configuration");
		}
		else {
			Sys.println("The following checks are missing from your configuration:");
			for (check in missingChecks) {
				Sys.println(check.name + " - " + check.description);
			}
		}
	}

	public static function main() {
		var args;
		var cwd;
		var oldCwd = null;

		try {
			args = Sys.args();

			#if neko
			// use the faster JS version if possible
			try {
				var process = new sys.io.Process("node", ["-v"]);
				var nodeExists = process.exitCode() == 0;
				process.close();
				if (nodeExists && FileSystem.exists("haxecheckstyle.js")) {
					var exitCode = Sys.command("node", ["haxecheckstyle.js"].concat(args));
					Sys.exit(exitCode);
				}
			}
			catch (e:Any) {}
			#end

			cwd = Sys.getCwd();
			if (Sys.getEnv("HAXELIB_RUN") != null) {
				cwd = args.pop();
				oldCwd = Sys.getCwd();
			}
			if (oldCwd != null) Sys.setCwd(cwd);

			new Main().run(args);
		}
		catch (e:Any) {
			Sys.stderr().writeString(e + "\n");
			Sys.stderr().writeString(CallStack.toString(CallStack.exceptionStack()) + "\n");
		}
		if (oldCwd != null) Sys.setCwd(oldCwd);
		Sys.exit(exitCode);
	}
}

typedef CodeclimateConfig = {
	@:optional var enabled:Bool;
	@:optional var include_paths:Array<String>;
	@:optional var config:String;
	@:optional var exclude:String;
}