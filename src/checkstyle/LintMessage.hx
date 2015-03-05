package checkstyle;

enum SeverityLevel {
	INFO;
	WARNING;
	ERROR;
}

typedef LintMessage = {
	var fileName:String;
	var message:String;
	var line:Int;
	var column:Int;
	var severity:SeverityLevel;
	var moduleName:String;
}