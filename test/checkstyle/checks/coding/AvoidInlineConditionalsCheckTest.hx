package checkstyle.checks.coding;

import checkstyle.SeverityLevel;

class AvoidInlineConditionalsCheckTest extends CheckTestCase<AvoidInlineConditionalsTests> {
	@Test
	public function testInlineCondition() {
		var check = new AvoidInlineConditionalsCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST1, "Avoid inline conditionals");
	}
}

@:enum
abstract AvoidInlineConditionalsTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var a:Array<Int> = [];
		var x = (a == null || a.length < 1) ? null : a[0];
	}";
}