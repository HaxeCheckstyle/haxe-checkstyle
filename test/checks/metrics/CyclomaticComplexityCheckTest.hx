package checks.metrics;

import checkstyle.checks.metrics.CyclomaticComplexityCheck;

class CyclomaticComplexityCheckTest extends CheckTestCase<CyclomaticComplexityCheckTests> {

	public function testCorrectNaming() {
		var check = new CyclomaticComplexityCheck();
		check.thresholds = [
			{ severity : "WARNING", complexity : 1 },
			{ severity : "ERROR", complexity : 2 }
		];
		assertMsg(check, TEST, 'Function "test" is too complex (score: 2).');

		check.thresholds = [
			{ severity : "IGNORE", complexity : 1 },
			{ severity : "IGNORE", complexity : 2 }
		];
		assertNoMsg(check, TEST);
	}
}

@:enum
abstract CyclomaticComplexityCheckTests(String) to String {
	var TEST = "
	class Test {
		function test() {
			var a:Array<Int> = [0, 5, 20];
			for (i in 0 ... a.length) {
				var b = Browser.document.createOptionElement();
				option.value = i;
				option.innerText = i;
			}
		}
	}";
}