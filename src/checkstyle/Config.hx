package checkstyle;

import checkstyle.LintMessage.SeverityLevel;

typedef Config = {
	var defaultSeverity:SeverityLevel;
	// defines that are always added
	var baseDefines:Array<String>;
	// different define combinations to use (on top of `defines`)
	var defineCombinations:Array<Array<String>>;
	var checks:Array<CheckConfig>;
}

@SuppressWarnings("checkstyle:Dynamic")
typedef CheckConfig = {
	var type:String;
	var props:Dynamic;
}