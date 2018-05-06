package checkstyle;

@:enum
abstract SeverityLevel(String) from String {
	var INFO = "INFO";
	var WARNING = "WARNING";
	var ERROR = "ERROR";
	var IGNORE = "IGNORE";
}