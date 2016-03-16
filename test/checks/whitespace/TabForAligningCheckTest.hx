package checks.whitespace;

import checkstyle.checks.whitespace.TabForAligningCheck;

class TabForAligningCheckTest extends CheckTestCase<TabForAligningCheckTests> {

	public function testTab() {
		assertMsg(new TabForAligningCheck(), TEST1, "Tab after non-space character, use space for aligning");
	}

	public function testMultiline() {
		assertNoMsg(new TabForAligningCheck(), TEST2);
	}
}

@:enum
abstract TabForAligningCheckTests(String) to String {
	var TEST1 = "
	class Test {
		static inline var TAB_FOR_ALIGNING_TEST:Int = 	1;

	}";

	var TEST2 =
	"class Test {
		public function test() {
			var a:Array<String> = ['one', 'two',
									'three'];
		}
	}";
}