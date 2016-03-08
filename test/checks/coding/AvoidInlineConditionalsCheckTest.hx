package checks.coding;

import checkstyle.checks.coding.AvoidInlineConditionalsCheck;

class AvoidInlineConditionalsCheckTest extends CheckTestCase<AvoidInlineConditionalsTests> {

	public function testInlineCondition() {
		assertMsg(new AvoidInlineConditionalsCheck(), TEST1, 'Avoid inline conditionals');
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