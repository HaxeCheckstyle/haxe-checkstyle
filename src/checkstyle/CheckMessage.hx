package checkstyle;

import checkstyle.checks.Category;

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