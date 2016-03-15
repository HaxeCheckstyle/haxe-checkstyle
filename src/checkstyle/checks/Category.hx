package checkstyle.checks;

@:enum
abstract Category(String) {
	var BUG_RISK = "Bug Risk";
	var CLARITY = "Clarity";
	var COMPATIBILITY = "Compatibility";
	var COMPLEXITY = "Complexity";
	var DUPLICATION = "Duplication";
	var PERFORMANCE = "Performance";
	var SECURITY = "Security";
	var STYLE = "Style";
}