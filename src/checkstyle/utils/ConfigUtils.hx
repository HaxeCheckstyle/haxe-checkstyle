package checkstyle.utils;

import checkstyle.Checker;
import checkstyle.ChecksInfo.CheckInfo;
import checkstyle.checks.Check;
import checkstyle.config.CheckConfig;
import checkstyle.config.Config;
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
			exclude: {},
			version: 1
		};
	}

	public static function saveConfig(checker:Checker, path:String) {
		var file = File.write(path, false);
		file.writeString(Json.stringify(makeConfigFromChecker(checker), null, "\t"));
		file.close();
	}

	public static function saveCheckConfigList(list:Array<CheckConfig>, path:String) {
		var file = File.write(path, false);
		file.writeString(Json.stringify(makeConfigFromList(list), null, "\t"));
		file.close();
	}

	public static function makeConfigFromChecker(checker:Checker):Config {
		var list:Array<CheckConfig> = [];
		for (check in checker.checks) list.push(makeCheckConfig(check));
		return makeConfigFromList(list);
	}

	public static function makeConfigFromList(list:Array<CheckConfig>):Config {
		var config:Config = getEmptyConfig();
		config.checks = list;
		ArraySort.sort(config.checks, checkConfigSort);
		return config;
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

	public static function checkInfoSort(a:CheckInfo, b:CheckInfo):Int {
		if (a.name == b.name) return 0;
		if (a.name < b.name) return -1;
		return 1;
	}

	public static function makeCheckConfig(check:Check):CheckConfig {
		var propsNotAllowed:Array<String> = [
			"moduleName",
			"severity",
			"type",
			"categories",
			"points",
			"desc",
			"currentState",
			"skipOverStringStart",
			"commentStartRE",
			"commentBlockEndRE",
			"stringStartRE",
			"stringInterpolatedEndRE",
			"stringLiteralEndRE",
			"formatRE",
			"skipOverInitialQuote",
			"messages",
			"checker",
			"placemap",
			"metaName",
			"ignoreRE"
		];
		var checkConfig:CheckConfig = {
			type: check.getModuleName(),
			props: {}
		};
		for (prop in Type.getInstanceFields(Type.getClass(check))) {
			if (propsNotAllowed.contains(prop)) continue;

			var value = Reflect.field(check, prop);
			if (Reflect.isFunction(value)) continue;
			Reflect.setField(checkConfig.props, prop, value);
		}
		return checkConfig;
	}
}