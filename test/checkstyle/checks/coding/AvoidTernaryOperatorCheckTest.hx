package checkstyle.checks.coding;

import checkstyle.SeverityLevel;

class AvoidTernaryOperatorCheckTest extends CheckTestCase<AvoidTernaryOperatorCheckTests> {
	@Test
	public function testInlineCondition() {
		var check = new AvoidTernaryOperatorCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST1, "Avoid ternary operator");
	}
}

enum abstract AvoidTernaryOperatorCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var a:Array<Int> = [];
		var x = (a == null || a.length < 1) ? null : a[0];
	}";
}