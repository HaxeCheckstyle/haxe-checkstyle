package checkstyle;

/**
	sets gravity of reported violations:
	- IGNORE = do not report violations, violations do not appear anywhere in output
	- INFO = all violations have info / lowest priority
	- WARNING = all violations have warning / medium priority
	- ERROR = all violations have error / highest priority
**/
enum abstract SeverityLevel(String) from String {
	var INFO = "INFO";
	var WARNING = "WARNING";
	var ERROR = "ERROR";
	var IGNORE = "IGNORE";
}