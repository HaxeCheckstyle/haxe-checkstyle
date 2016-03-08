package checks.whitespace;

import checkstyle.checks.whitespace.TabForAligningCheck;

class TabForAligningCheckTest extends CheckTestCase<TabForAligningCheckTests> {

	public function testTab() {
		assertMsg(new TabForAligningCheck(), TEST1, 'Tab after non-space character. Use space for aligning');
	}

	public function testMultiline() {
		assertNoMsg(new TabForAligningCheck(), TEST2);
	}
}

@:enum
abstract TabForAligningCheckTests(String) to String {
	var TEST1 = "
	class Test {
		var a:Int = 	1;

	}";

	var TEST2 =
	"class Test {
		public function test() {
			var a:Array<String> = ['one', 'two',
									'three'];
		}
	}";
}