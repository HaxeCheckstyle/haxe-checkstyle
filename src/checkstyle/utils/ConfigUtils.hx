package checkstyle.utils;

import checkstyle.Config;
import checkstyle.Checker;

import haxe.Json;
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
		var propsNotAllowed:Array<String> = [
			"moduleName", "severity", "type", "categories",
			"points", "desc", "currentState", "skipOverStringStart",
			"commentStartRE", "commentBlockEndRE", "stringStartRE",
			"stringInterpolatedEndRE", "stringLiteralEndRE",
			"skipOverInitialQuote", "messages", "checker"
		];
		var config = getEmptyConfig();
		for (check in checker.checks) {
			var checkConfig:CheckConfig = {
				type: check.getModuleName(),
				props: {}
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
	}
}