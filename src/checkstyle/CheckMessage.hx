package checkstyle;

import checkstyle.checks.Category;

@:enum
abstract SeverityLevel(String) from String {
	var INFO = "INFO";
	var WARNING = "WARNING";
	var ERROR = "ERROR";
	var IGNORE = "IGNORE";
}

typedef CheckMessage = {
	var fileName:String;
	var message:String;
	var desc:String;
	var line:Int;
	var startColumn:Int;
	var endColumn:Int;
	var severity:SeverityLevel;
	var moduleName:String;
	var categories:Array<Category>;
	var points:Int;
}