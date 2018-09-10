package checks.whitespace;

import checkstyle.SeverityLevel;
import checkstyle.checks.whitespace.TabForAligningCheck;

class TabForAligningCheckTest extends CheckTestCase<TabForAligningCheckTests> {
	@Test
	public function testTab() {
		var check = new TabForAligningCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST1, "Tab after non-space character, use space for aligning");
	}

	@Test
	public function testMultiline() {
		var check = new TabForAligningCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TEST2);
	}
}

@:enum
abstract TabForAligningCheckTests(String) to String {
	var TEST1 = "
	class Test {
		static inline var TAB_FOR_ALIGNING_TEST:Int = 	1;

	}";
	var TEST2 = "
	class Test {
		public function test() {
			var a:Array<String> = ['one', 'two',
									'three'];
		}
	}";
}