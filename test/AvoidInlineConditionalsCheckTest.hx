import checkstyle.checks.AvoidInlineConditionalsCheck;

class AvoidInlineConditionalsCheckTest extends CheckTestCase {

	public function testInlineCondition() {
		assertMsg(new AvoidInlineConditionalsCheck(), AvoidInlineConditionalsTests.TEST1, 'Avoid inline conditionals');
	}
}

class AvoidInlineConditionalsTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		var a:Array<Int> = [];
		var x = (a == null || a.length < 1) ? null : a[0];
	}";
}