package checkstyle.detect;

enum DetectionResult {
	NO_CHANGE;
	CHANGE_DETECTED(value:Any);
	REDUCED_VALUE_LIST(value:Any);
}