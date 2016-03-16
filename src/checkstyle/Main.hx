package checkstyle;

import checkstyle.ChecksInfo;
import checkstyle.Config;
import checkstyle.CheckMessage.SeverityLevel;
import checkstyle.checks.Check;
import checkstyle.reporter.IReporter;
import checkstyle.reporter.JSONReporter;
import checkstyle.reporter.ProgressReporter;
import checkstyle.reporter.TextReporter;
import checkstyle.reporter.XMLReporter;
import checkstyle.reporter.CodeClimateReporter;
import checkstyle.reporter.ExitCodeReporter;
import haxe.CallStack;
import haxe.Json;
import hxargs.Args;
import sys.FileSystem;
import sys.io.File;

using checkstyle.utils.ArrayUtils;
using checkstyle.utils.StringUtils;

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
	static var exitCode:Int;

	var info:ChecksInfo;
	var checker:Checker;
	var paths:Array<String>;
	var allExcludes:Array<String>;
	var excludesMap:Map<String, Array<String>>;
	var configPath:String;
	var excludePath:String;

	function new() {
		info = new ChecksInfo();
		checker = new Checker();
		paths = [];
		allExcludes = [];
		excludesMap = new Map();
		exitCode = 0;
		configPath = null;
		excludePath = null;
	}

	function run(args:Array<String>) {
		var argHandler = Args.generate([
			@doc("Set source folder to process (multiple allowed)") ["-s", "--source"] => function(path:String) paths.push(path),
			@doc("Set config file (default: checkstyle.json)") ["-c", "--config"] => function(path:String) configPath = path,
			@doc("Set exclude config file (default: checkstyle-exclude.json)") ["-e", "--exclude"] => function(path:String) excludePath = path,
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
			@doc("To omit styling in output summary") ["-nostyle"] => function() NO_STYLE = true,
			@doc("Show report [DEPRECATED]") ["-report"] => function() trace("-report is no longer needed"),
			_ => function(arg:String) failWith("Unknown command: " + arg)
		]);

		if (args.length == 0) {
			Sys.println(argHandler.getDoc());
			Sys.exit(0);
		}
		argHandler.parse(args);

		if (REPORT_TYPE == "codeclimate") {
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

		if (configPath == null) addAllChecks();
		else loadConfig(configPath);

		if (excludePath != null) loadExcludeConfig(excludePath);
		else start();
	}

	function loadConfig(path:String) {
		var config:Config = Json.parse(File.getContent(path));
		validateAllowedFields(config, Reflect.fields(getEmptyConfig()), "Config");

		if (config.exclude != null) parseExcludes(config.exclude);

		for (checkConf in config.checks) {
			var check = createCheck(checkConf);
			setCheckProperties(check, checkConf, config.defaultSeverity);
		}

		if (config.baseDefines != null) {
			validateDefines(config.baseDefines);
			checker.baseDefines = config.baseDefines;
		}
		if (config.defineCombinations != null) {
			for (combination in config.defineCombinations) validateDefines(combination);
			checker.defineCombinations = config.defineCombinations;
		}
	}

	function loadExcludeConfig(path:String) {
		var config = Json.parse(File.getContent(path));
		parseExcludes(config);
		start();
	}

	function parseExcludes(config:ExcludeConfig) {
		var excludes = Reflect.fields(config);
		for (exclude in excludes) {
			createExcludeMapElement(exclude);
			var excludeValues:Array<String> = Reflect.field(config, exclude);
			if (excludeValues == null || excludeValues.length == 0) continue;
			for (val in excludeValues) updateExcludes(exclude, val);
		}
	}

	function createExcludeMapElement(exclude:String) {
		if (excludesMap.get(exclude) == null) excludesMap.set(exclude, []);
	}

	function updateExcludes(exclude:String, val:String) {
		for (p in paths) {
			var path = p + "/" + val.split(".").join("/");
			if (exclude == "all") allExcludes.push(path);
			else excludesMap.get(exclude).push(path);
		}
	}

	function createCheck(checkConf:CheckConfig):Check {
		var check:Check = info.build(checkConf.type);
		if (check == null) failWith('Unknown check \'${checkConf.type}\'');
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
			Reflect.setField(check, prop, val);
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
			case "xml": new XMLReporter(numFiles, XML_PATH, STYLE, NO_STYLE);
			case "json": new JSONReporter(numFiles, JSON_PATH, NO_STYLE);
			case "text": new TextReporter(numFiles, TEXT_PATH, NO_STYLE);
			case "codeclimate": new CodeClimateReporter(numFiles, null, NO_STYLE);
			default: failWith('Unknown reporter: $REPORT_TYPE'); null;
		}
	}

	function listReporters() {
		Sys.println("text - Text reporter (default)");
		Sys.println("xml - XML reporter");
		Sys.println("json - JSON reporter");
		Sys.exit(0);
	}

	function getEmptyConfig():Config {
		return {
			defaultSeverity: SeverityLevel.INFO,
			baseDefines: [],
			defineCombinations: [],
			checks: [],
			exclude: {}
		};
	}

	function generateDefaultConfig(path) {
		addAllChecks();

		var propsNotAllowed:Array<String> = ["moduleName", "severity", "type", "categories", "points", "desc"];
		var config = getEmptyConfig();
		for (check in checker.checks) {
			var checkConfig:CheckConfig = {
				type: check.getModuleName(),
				props: {
					severity: SeverityLevel.IGNORE
				}
			};
			for (prop in Reflect.fields(check)) {
				if (propsNotAllowed.contains(prop)) continue;
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

	function start() {
		var files:Array<String> = [];
		for (path in paths) traverse(path, files);
		files.sortStrings();

		var i:Int = 0;
		var toProcess:Array<CheckFile> = [for (file in files) { name:file, content:null, index:i++ }];

		checker.addReporter(createReporter(files.length));
		if (SHOW_PROGRESS) checker.addReporter(new ProgressReporter(files.length));
		if (EXIT_CODE) checker.addReporter(new ExitCodeReporter());
		checker.process(toProcess, excludesMap);
	}

	function traverse(path:String, files:Array<String>) {
		try {
			if (FileSystem.isDirectory(path) && !allExcludes.contains(path)) {
				var nodes = FileSystem.readDirectory(path);
				for (child in nodes) traverse(pathJoin(path, child), files);
			}
			else if (~/(.hx)$/i.match(path) && !allExcludes.contains(path.substring(0, path.indexOf(".hx")))) {
				files.push(path);
			}
		}
		catch (e:Dynamic) {
			Sys.println("\nPath " + path + " not found.");
		}
	}

	function failWith(message:String) {
		Sys.stderr().writeString(message + "\n");
		Sys.exit(1);
	}

	public static function setExitCode(newExitCode:Int) {
		exitCode = newExitCode;
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
		catch (e:Dynamic) {
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