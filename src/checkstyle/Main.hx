package checkstyle;

import checkstyle.ChecksInfo;
import checkstyle.Config;
import checkstyle.checks.Check;
import checkstyle.reporter.IReporter;
import checkstyle.reporter.JSONReporter;
import checkstyle.reporter.ProgressReporter;
import checkstyle.reporter.TextReporter;
import checkstyle.reporter.XMLReporter;
import checkstyle.reporter.CodeClimateReporter;
import checkstyle.reporter.ExitCodeReporter;
import checkstyle.reporter.ReporterManager;
import checkstyle.errors.Error;
import checkstyle.detect.DetectCodingStyle;
import checkstyle.utils.ConfigUtils;
import haxe.CallStack;
import haxe.Json;
import hxargs.Args;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

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

	var info:ChecksInfo;
	var checker:Checker;
	var paths:Array<String>;
	var allExcludes:Array<String>;
	var excludesMap:Map<String, Array<String>>;
	var configPath:String;
	var excludePath:String;
	var numberOfCheckerThreads:Int;
	var overrideCheckerThreads:Int;
	var disableThreads:Bool;
	var detectConfig:String;
	var seenConfigPaths:Array<String>;

	function new() {
		info = new ChecksInfo();
		checker = new Checker();
		paths = [];
		allExcludes = [];
		seenConfigPaths = [];
		excludesMap = new Map();
		exitCode = 0;
		configPath = null;
		excludePath = null;
		numberOfCheckerThreads = 5;
		overrideCheckerThreads = 0;
		detectConfig = null;
	}

	function run(args:Array<String>) {
		var argHandler = Args.generate([
			@doc("Set source path to process (multiple allowed)") ["-s", "--source"] => function(path:String) paths.push(path),
			@doc("Set config file (default: checkstyle.json)") ["-c", "--config"] => function(path:String) configPath = path,
			@doc("Set exclude file (default: checkstyle-exclude.json)") ["-e", "--exclude"] => function(path:String) excludePath = path,
			@doc("Set reporter (xml, json or text, default: text)") ["-r", "--reporter"] => function(name:String) REPORT_TYPE = name,
			@doc("Set reporter output path") ["-p", "--path"] => function(path:String) {
				XML_PATH = path;
				JSON_PATH = path;
				TEXT_PATH = path;
			},
			@doc("Set reporter style (XSLT)") ["-x", "--xslt"] => function(style:String) STYLE = style,
			@doc("Sets the number of checker threads") ["-checkerthreads"] => function (num:Int) overrideCheckerThreads = num,
			@doc("Generate a default config and exit") ["-default-config", "--default-config"] => function(path) generateDefaultConfig(path),
			@doc("Try to detect your coding style (experimental)") ["-detect"] => function (path) detectCodingStyle(path),
			@doc("Return number of failed checks in exitcode") ["-exitcode"] => function() EXIT_CODE = true,
			@doc("List all available checks and exit") ["-list-checks", "--list-checks"] => function() listChecks(),
			@doc("List all available reporters and exit") ["-list-reporters", "--list-reporters"] => function() listReporters(),
			@doc("Omit styling in output summary") ["-nostyle"] => function() NO_STYLE = true,
			@doc("Do not use checker threads") ["-nothreads"] => function () disableThreads = true,
			@doc("Show percentage progress") ["-progress"] => function() SHOW_PROGRESS = true,
			@doc("Show checks missing from active config") ["-show-missing-checks"] => function () SHOW_MISSING_CHECKS = true,
			@doc("Adds error messages for files that checkstyle fails to parse") ["-show-parser-errors"] => function ()
				ReporterManager.SHOW_PARSE_ERRORS = true,
			_ => function(arg:String) failWith("Unknown command: " + arg)
		]);

		if (args.length == 0) {
			Sys.println(argHandler.getDoc());
			Sys.exit(0);
		}
		argHandler.parse(args);

		if (REPORT_TYPE == CODE_CLIMATE_REPORTER) {
			var defaultConfig:CodeclimateConfig = Json.parse(File.getContent("/config.json"));
			if (defaultConfig.include_paths != null && defaultConfig.include_paths.length > 0) {
				for (s in defaultConfig.include_paths) {
					if (s != ".codeclimate.yml") paths.push("/code/" + s);
				}
			}
			else paths.push("/code");

			if (defaultConfig.config != null) configPath = defaultConfig.config;
			if (defaultConfig.exclude != null) excludePath = defaultConfig.exclude;
			if (paths.length > 0) processArgs();
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

		loadConfig(configPath);
		if (excludePath != null) loadExcludeConfig(excludePath);
		start();
	}

	public function loadConfig(path:String) {
		if (path != null && FileSystem.exists(path) && !FileSystem.isDirectory(path)) {
			seenConfigPaths.push(path);
			parseAndValidateConfig(Json.parse(File.getContent(path)));
		}
		else addAllChecks();
	}

	public function parseAndValidateConfig(config:Config) {

		validateAllowedFields(config, Reflect.fields(ConfigUtils.getEmptyConfig()), "Config");

		if (!config.extendsConfigPath.isEmpty()) {
			if (seenConfigPaths.contains(config.extendsConfigPath)) failWith("extendsConfig: config file loop detected!");
			seenConfigPaths.push(config.extendsConfigPath);
			if (FileSystem.exists(config.extendsConfigPath) && !FileSystem.isDirectory(config.extendsConfigPath)) {
				parseAndValidateConfig(Json.parse(File.getContent(config.extendsConfigPath)));
			}
			else failWith('extendsConfig: Failed to load parent configuration file [${config.extendsConfigPath}]');
		}

		if (config.exclude != null) parseExcludes(config.exclude);

		if (config.checks != null) {
			for (checkConf in config.checks) {
				var check = createCheck(checkConf);
				if (check != null) setCheckProperties(check, checkConf, config.defaultSeverity);
			}
		}

		if (config.baseDefines != null) {
			validateDefines(config.baseDefines);
			checker.baseDefines = config.baseDefines;
		}
		if (config.defineCombinations != null) {
			for (combination in config.defineCombinations) validateDefines(combination);
			checker.defineCombinations = config.defineCombinations;
		}
		validateCheckerThreads(config.numberOfCheckerThreads);
	}

	public function loadExcludeConfig(path:String) {
		var config = Json.parse(File.getContent(path));
		parseExcludes(config);
	}

	function parseExcludes(config:ExcludeConfig) {
		var excludes = Reflect.fields(config);
		var pathType = Reflect.field(config, "path");
		for (exclude in excludes) {
			if (exclude == "path") continue;
			createExcludeMapElement(exclude);
			var excludeValues:Array<String> = Reflect.field(config, exclude);
			if (excludeValues == null || excludeValues.length == 0) continue;
			for (val in excludeValues) updateExcludes(exclude, val, pathType);
		}
	}

	function createExcludeMapElement(exclude:String) {
		if (excludesMap.get(exclude) == null) excludesMap.set(exclude, []);
	}

	function updateExcludes(exclude:String, val:String, pathType:ExcludePath) {
		if (pathType == null) {
			addToExclude(exclude, val);
		}
		else {
			if (pathType == RELATIVE_TO_SOURCE) {
				for (path in paths) {
					addNormalisedPathToExclude(exclude, path + ":" + val);
				}
			}
			else {
				addNormalisedPathToExclude(exclude, val);
			}
		}
	}

	function addNormalisedPathToExclude(exclude:String, path:String) {
		var path = normalisePath(path);
		addToExclude(exclude, path);
	}

	function normalisePath(path:String):String {
		var slashes:EReg = ~/[\/\\]/g;
		path = path.split(".").join(":");
		path = slashes.replace(path, ":");
		return path;
	}

	function addToExclude(exclude:String, value:String) {
		if (exclude == "all") allExcludes.push(value);
		else excludesMap.get(exclude).push(value);
	}

	function createCheck(checkConf:CheckConfig):Check {
		var check:Check = info.build(checkConf.type);
		if (check == null) {
			Sys.stdout().writeString('Unknown check \'${checkConf.type}\'');
			return null;
		}
		checker.addCheck(check);
		return check;
	}

	function setCheckProperties(check:Check, checkConf:CheckConfig, defaultSeverity:SeverityLevel) {
		validateAllowedFields(checkConf, ["type", "props"], check.getModuleName());
		var props = (checkConf.props == null) ? [] : Reflect.fields(checkConf.props);
		// use Type.getInstanceFields to make it work in c++ / profiler
		var checkFields:Array<String> = Type.getInstanceFields(Type.getClass(check));
		for (prop in props) {
			var val = Reflect.field(checkConf.props, prop);
			if (!checkFields.contains(prop)) {
				failWith('Check ${check.getModuleName()} has no property named \'$prop\'');
			}
			try {
				check.configureProperty(prop, val);
			}
			catch (e:Any) {
				var message = 'Failed to configure $prop setting for ${check.getModuleName()}: ';
				message += (Std.is(e, Error) ? (e:Error).message : Std.string(e));
				failWith(message);
			}
		}
		if (defaultSeverity != null && !props.contains("severity")) check.severity = defaultSeverity;
	}

	function validateAllowedFields<T>(object:T, allowedFields:Array<String>, messagePrefix:String) {
		for (field in Reflect.fields(object)) {
			if (!allowedFields.contains(field)) {
				failWith(messagePrefix + " has unknown field '" + field + "'");
			}
		}
	}

	function validateDefines(defines:Array<String>) {
		for (define in defines) {
			if (define.split("=").length > 2) throw "Found a define with more than one = sign: '" + define + "'";
		}
	}

	function validateCheckerThreads(checkerThreads:Null<Int>) {
		if (checkerThreads != null) {
			numberOfCheckerThreads = checkerThreads;
		}
		if (overrideCheckerThreads > 0) numberOfCheckerThreads = overrideCheckerThreads;
		if (numberOfCheckerThreads <= 0) numberOfCheckerThreads = 5;
		if (numberOfCheckerThreads > 15) numberOfCheckerThreads = 15;
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
		var count = 0;
		for (check in getSortedCheckInfos()) {
			Sys.println(check.name + ":");
			Sys.println("  " + check.description + "\n");
			if (~/\[DEPRECATED/.match(check.description)) continue;
			count++;
		}
		Sys.println("Total: " + count + " checks");
		Sys.exit(0);
	}

	function getCheckCount():Int {
		var count = 0;
		for (check in info.checks()) {
			if (~/\[DEPRECATED/.match(check.description)) continue;
			count++;
		}
		return count;
	}

	function getUsedCheckCount():Int {
		var count = 0;
		var list:Array<String> = [];
		for (check in checker.checks) {
			var name = Type.getClassName(Type.getClass(check));
			if (list.indexOf(name) >= 0) continue;
			list.push(name);
			count++;
		}
		return count;
	}

	function createReporter(numFiles:Int):IReporter {
		var totalChecks = getCheckCount();
		var checksUsed = getUsedCheckCount();
		return switch (REPORT_TYPE) {
			case "xml": new XMLReporter(numFiles, totalChecks, checksUsed, XML_PATH, STYLE, NO_STYLE);
			case "json": new JSONReporter(numFiles, totalChecks, checksUsed, JSON_PATH, NO_STYLE);
			case "text": new TextReporter(numFiles, totalChecks, checksUsed, TEXT_PATH, NO_STYLE);
			case "codeclimate": new CodeClimateReporter(numFiles, totalChecks, checksUsed, null, NO_STYLE);
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
		ConfigUtils.saveConfig(checker, path);
		Sys.exit(0);
	}

	function detectCodingStyle(path:String) {
		var checks:Array<Check> = [];
		for (checkInfo in info.checks()) {
			if (checkInfo.isAlias) continue;
			var check:Check = info.build(checkInfo.name);
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
			checker.process(toProcess, excludesMap);
		}
		else {
			ReporterManager.INSTANCE.start();
			var parserQueue:ParserQueue = new ParserQueue(toProcess, checker);
			var preParseCount:Int = numberOfCheckerThreads * 3;
			if (preParseCount < 15) preParseCount = 15;
			parserQueue.start(preParseCount);
			var checkerPool:CheckerPool = new CheckerPool(parserQueue, checker, excludesMap);
			checkerPool.start(numberOfCheckerThreads);

			while (!checkerPool.isFinished()) Sys.sleep(0.1);
			ReporterManager.INSTANCE.finish();
		}
		#else
		checker.process(toProcess, excludesMap);
		#end
	}

	function buildFileList():Array<CheckFile> {
		var files:Array<String> = [];
		for (path in paths) traverse(path, files);
		files.sortStrings();

		var i:Int = 0;
		return [for (file in files) { name:file, content:null, index:i++ }];
	}

	function traverse(path:String, files:Array<String>) {
		try {
			if (FileSystem.isDirectory(path) && !isExcludedFromAll(path)) {
				var nodes = FileSystem.readDirectory(path);
				for (child in nodes) traverse(Path.join([path, child]), files);
			}
			else if (~/(.hx)$/i.match(path) && !isExcludedFromAll(path)) {
				files.push(path);
			}
		}
		catch (e:Any) {
			Sys.println("\nPath " + path + " not found.");
		}
	}

	function isExcludedFromAll(path:String):Bool {
		var offset = path.indexOf(".hx");
		if (offset > 0) {
			path = path.substring(0, offset);
		}
		if (allExcludes.contains(path)) return true;

		var slashes:EReg = ~/[\/\\]/g;
		path = slashes.replace(path, ":");
		for (exclude in allExcludes) {
			var r = new EReg(exclude, "i");
			if (r.match(path)) return true;
		}
		return false;
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
		for (check in info.checks()) {
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

@:enum
abstract ExcludePath(String) {
	var RELATIVE_TO_PROJECT = "RELATIVE_TO_PROJECT";
	var RELATIVE_TO_SOURCE = "RELATIVE_TO_SOURCE";
}