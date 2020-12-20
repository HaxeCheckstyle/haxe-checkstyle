package checkstyle.config;

import checkstyle.Checker;
import checkstyle.ChecksInfo;
import checkstyle.checks.Check;
import checkstyle.errors.Error;
import checkstyle.utils.ConfigUtils;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

#if (haxe >= version("4.1.0"))
import Std.isOfType as isOfType;
#else
import Std.is as isOfType;
#end

class ConfigParser {
	public var paths:Array<String>;
	public var excludesMap:Map<String, Array<String>>;
	public var allExcludes:Array<String>;
	public var numberOfCheckerThreads:Int;
	public var overrideCheckerThreads:Int;
	public var info:ChecksInfo;
	public var checker:Checker;
	public var validateMode:ConfigValidateMode;

	var seenConfigPaths:Array<String>;
	var failWithCallback:String -> Void;

	public function new(failCallback:String -> Void) {
		info = new ChecksInfo();
		checker = new Checker();
		failWithCallback = failCallback;

		paths = [];
		allExcludes = [];
		seenConfigPaths = [];
		excludesMap = new Map();
		numberOfCheckerThreads = 5;
		overrideCheckerThreads = 0;
		validateMode = STRICT;
	}

	public function loadConfig(path:String) {
		path = getAbsoluteConfigPath(path, Sys.getCwd());
		if (path != null && FileSystem.exists(path) && !FileSystem.isDirectory(path)) {
			seenConfigPaths.push(path);
			parseAndValidateConfig(Json.parse(File.getContent(path)), Path.directory(path));
		}
		else addAllChecks();
	}

	function getAbsoluteConfigPath(path:String, baseFolder:String):String {
		if (path == null) return null;
		if (Path.isAbsolute(path)) return path;
		return Path.join([baseFolder, path]);
	}

	public function parseAndValidateConfig(config:Config, rootFolder:String) {
		validateAllowedFields(config, Reflect.fields(ConfigUtils.getEmptyConfig()), "Config");
		if (config.version == null) config.version = 1;
		if (config.version != 1) failWith('configuration file has unknown version: ${config.version}');

		if (!config.extendsConfigPath.isEmpty()) {
			var path:String = getAbsoluteConfigPath(config.extendsConfigPath, rootFolder);
			if (seenConfigPaths.contains(path)) failWith("extendsConfig: config file loop detected!");
			seenConfigPaths.push(path);
			if (FileSystem.exists(path) && !FileSystem.isDirectory(path)) {
				parseAndValidateConfig(Json.parse(File.getContent(path)), Path.directory(path));
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

	public function parseExcludes(config:ExcludeConfig) {
		if (config.version == null) config.version = 1;
		if (config.version != 1) failWith('exclude configuration file has unknown version: ${config.version}');
		var pathType = config.path;
		var excludes = Reflect.fields(config);
		for (exclude in excludes) {
			if (exclude == "path") continue;
			if (exclude == "version") continue;
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
		var range:String = null;
		var index:Int = val.lastIndexOf(":");
		if (index > 0) {
			range = val.substr(index + 1);
			val = val.substr(0, index);
		}
		if ((pathType == null) || (pathType == cast "")) {
			addNormalisedPathToExclude(exclude, val, range);
			return;
		}
		switch (pathType) {
			case RELATIVE_TO_SOURCE:
				for (path in paths) {
					addNormalisedPathToExclude(exclude, path + ":" + val, range);
				}
			case RELATIVE_TO_PROJECT:
				addNormalisedPathToExclude(exclude, val, range);
		}
	}

	function addNormalisedPathToExclude(exclude:String, path:String, range:String) {
		var path = normalisePath(path);
		addToExclude(exclude, path, range);
	}

	function normalisePath(path:String):String {
		var slashes:EReg = ~/[\/\\]/g;
		path = path.split(".").join(":");
		path = slashes.replace(path, ":");
		return path;
	}

	function addToExclude(exclude:String, value:String, range:String) {
		if (exclude == "all") ExcludeManager.addGlobalExclude(value, range);
		else ExcludeManager.addConfigExclude(exclude, value, range);
	}

	function createCheck(checkConf:CheckConfig):Check {
		var check:Check = info.build(checkConf.type);
		if (check == null) {
			switch (validateMode) {
				case STRICT:
					failWith('Unknown check "${checkConf.type}"');
				case RELAXED:
			}
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
				continue;
			}
			try {
				check.configureProperty(prop, val);
			}
			catch (e:Any) {
				var message = 'Failed to configure $prop setting for ${check.getModuleName()}: ';
				message += (isOfType(e, Error) ? (e : Error).message : Std.string(e));
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
			if (define.split("=").length > 2) failWith("Found a define with more than one = sign: '" + define + "'");
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

	public function addAllChecks() {
		for (check in getSortedCheckInfos()) {
			if (!check.isAlias) checker.addCheck(info.build(check.name));
		}
	}

	public function getSortedCheckInfos():Array<CheckInfo> {
		var checks:Array<CheckInfo> = [for (check in info.checks()) check];
		checks.sort(ConfigUtils.checkInfoSort);
		return checks;
	}

	public function getCheckCount():Int {
		var count = 0;
		for (check in info.checks()) {
			if (~/\[DEPRECATED/.match(check.description)) continue;
			count++;
		}
		return count;
	}

	public function getUsedCheckCount():Int {
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

	function failWith(msg:String) {
		switch (validateMode) {
			case STRICT:
				failWithCallback(msg);
			case RELAXED:
		}
	}
}

enum ConfigValidateMode {
	STRICT;
	RELAXED;
}