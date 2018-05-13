package checkstyle.utils;

import checkstyle.Config;
import checkstyle.Checker;
import checkstyle.checks.Check;

import haxe.Json;
import haxe.ds.ArraySort;
import sys.io.File;

class ConfigUtils {

	public static function getEmptyConfig():Config {
		return {
			defaultSeverity: SeverityLevel.INFO,
			extendsConfigPath: "",
			numberOfCheckerThreads: 5,
			baseDefines: [],
			defineCombinations: [],
			checks: [],
			exclude: {}
		};
	}

	public static function saveConfig(checker:Checker, path:String) {
		var config = getEmptyConfig();
		for (check in checker.checks) config.checks.push(makeCheckConfig(check));
		ArraySort.sort(config.checks, checkConfigSort);

		var file = File.write(path, false);
		file.writeString(Json.stringify(config, null, "\t"));
		file.close();
	}

	public static function saveCheckConfigList(list:Array<CheckConfig>, path:String) {
		var config = getEmptyConfig();
		config.checks = list;
		ArraySort.sort(config.checks, checkConfigSort);

		var file = File.write(path, false);
		file.writeString(Json.stringify(config, null, "\t"));
		file.close();
	}

	public static function checkConfigSort(a:CheckConfig, b:CheckConfig):Int {
		if (a.type == b.type) return 0;
		if (a.type < b.type) return -1;
		return 1;
	}

	public static function checkSort(a:Check, b:Check):Int {
		if (a.getModuleName() == b.getModuleName()) return 0;
		if (a.getModuleName() < b.getModuleName()) return -1;
		return 1;
	}

	public static function makeCheckConfig(check:Check):CheckConfig {
		var propsNotAllowed:Array<String> = [
			"moduleName", "severity", "type", "categories",
			"points", "desc", "currentState", "skipOverStringStart",
			"commentStartRE", "commentBlockEndRE", "stringStartRE",
			"stringInterpolatedEndRE", "stringLiteralEndRE", "formatRE",
			"skipOverInitialQuote", "messages", "checker"
		];
		var checkConfig:CheckConfig = {
			type: check.getModuleName(),
			props: {}
		};
		for (prop in Reflect.fields(check)) {
			if (propsNotAllowed.contains(prop)) continue;
			Reflect.setField(checkConfig.props, prop, Reflect.field(check, prop));
		}
		return checkConfig;
	}
}