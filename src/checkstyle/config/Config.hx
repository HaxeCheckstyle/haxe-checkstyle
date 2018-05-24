package checkstyle.config;

import checkstyle.SeverityLevel;

typedef Config = {
	@:optional var extendsConfigPath:String;
	@:optional var defaultSeverity:SeverityLevel;
	// defines that are always added
	@:optional var baseDefines:Array<String>;
	// different define combinations to use (on top of `defines`)
	@:optional var defineCombinations:Array<Array<String>>;
	@:optional var numberOfCheckerThreads:Int;
	@:optional var checks:Array<CheckConfig>;
	@:optional var exclude:ExcludeConfig;
	@:optional var version:Int;
}