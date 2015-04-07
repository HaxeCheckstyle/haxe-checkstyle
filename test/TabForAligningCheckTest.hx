package ;

import checkstyle.checks.TabForAligningCheck;

class TabForAligningCheckTest extends CheckTestCase {

	public function testTab() {
		var msg = checkMessage(TabForAlignTests.TEST1, new TabForAligningCheck());
		assertEquals(msg, 'Tab after non-space character. Use space for aligning');
	}

	public function testMultiline() {
		var msg = checkMessage(TabForAlignTests.TEST2, new TabForAligningCheck());
		assertEquals(msg, '');
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