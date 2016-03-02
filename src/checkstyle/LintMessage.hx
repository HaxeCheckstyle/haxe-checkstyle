package checkstyle;

@SuppressWarnings('checkstyle:MemberName')
enum SeverityLevel {
	INFO;
	WARNING;
	ERROR;
	IGNORE;
}

typedef LintMessage = {
	var fileName:String;
	var message:String;
	var line:Int;
	var startColumn:Int;
	var endColumn:Int;
	var severity:SeverityLevel;
	var moduleName:String;
}