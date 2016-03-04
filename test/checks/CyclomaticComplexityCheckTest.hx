package checks;

import checkstyle.checks.CyclomaticComplexityCheck;

class CyclomaticComplexityCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new CyclomaticComplexityCheck();
		check.thresholds = [
			{ severity : "WARNING", complexity : 1 },
			{ severity : "ERROR", complexity : 2 }
		];
		assertMsg(check, CyclomaticComplexityTests.TEST, 'Function "test" is too complex (score: 2).');
	}

}

class CyclomaticComplexityTests {
	public static inline var TEST:String = "
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