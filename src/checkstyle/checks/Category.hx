package checkstyle.checks;

enum abstract Category(String) {
	var BUG_RISK = "Bug Risk";
	var CLARITY = "Clarity";
	var COMPLEXITY = "Complexity";
	var DUPLICATION = "Duplication";
	var STYLE = "Style";
}