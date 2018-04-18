package checkstyle;

import checkstyle.CheckMessage.SeverityLevel;

typedef Config = {
	@:optional var defaultSeverity:SeverityLevel;
	// defines that are always added
	@:optional var baseDefines:Array<String>;
	// different define combinations to use (on top of `defines`)
	@:optional var defineCombinations:Array<Array<String>>;
	@:optional var numberOfCheckerThreads:Int;
	@:optional var checks:Array<CheckConfig>;
	@:optional var exclude:ExcludeConfig;
}

typedef CheckConfig = {
	var type:String;
	@:optional var props:{};
}

typedef ExcludeConfig = {}