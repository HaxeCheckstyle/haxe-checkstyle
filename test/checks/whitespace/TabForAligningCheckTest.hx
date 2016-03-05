package checks.whitespace;

import checkstyle.checks.whitespace.TabForAligningCheck;

class TabForAligningCheckTest extends CheckTestCase {

	public function testTab() {
		assertMsg(new TabForAligningCheck(), TabForAlignTests.TEST1, 'Tab after non-space character. Use space for aligning');
	}

	public function testMultiline() {
		assertNoMsg(new TabForAligningCheck(), TabForAlignTests.TEST2);
	}
}

class TabForAlignTests {
	public static inline var TEST1:String = "
	class Test {
		var a:Int = 	1;

	}";

	public static inline var TEST2:String =
	"class Test {
		public function test() {
			var a:Array<String> = ['one', 'two',
									'three'];
		}
	}";
}