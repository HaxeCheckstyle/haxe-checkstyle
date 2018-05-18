package checkstyle.config;

@:enum
abstract ExcludePath(String) {
	var RELATIVE_TO_PROJECT = "RELATIVE_TO_PROJECT";
	var RELATIVE_TO_SOURCE = "RELATIVE_TO_SOURCE";
}