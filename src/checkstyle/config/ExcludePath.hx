package checkstyle.config;

/**
	filters excludes relative to
	- RELATIVE_TO_PROJECT = use project root
	- RELATIVE_TO_SOURCE = use path(s) specified via "-s <path>" command line switches
**/
enum abstract ExcludePath(String) {
	var RELATIVE_TO_PROJECT = "RELATIVE_TO_PROJECT";
	var RELATIVE_TO_SOURCE = "RELATIVE_TO_SOURCE";
}