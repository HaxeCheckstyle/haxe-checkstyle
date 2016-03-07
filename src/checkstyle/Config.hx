package checkstyle;

import checkstyle.LintMessage.SeverityLevel;

typedef Config = {
	var defaultSeverity:SeverityLevel;
	var checks:Array<CheckConfig>;
}

@SuppressWarnings("checkstyle:Dynamic")
typedef CheckConfig = {
	var type:String;
	var props:Dynamic;
}