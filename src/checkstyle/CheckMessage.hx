package checkstyle;

import checkstyle.checks.Category;

typedef CheckMessage = {
	var fileName:String;
	var message:String;
	var code:String;
	var desc:String;
	var startLine:Int;
	var endLine:Int;
	var startColumn:Int;
	var endColumn:Int;
	var severity:SeverityLevel;
	var moduleName:String;
	var categories:Array<Category>;
	var points:Int;
}