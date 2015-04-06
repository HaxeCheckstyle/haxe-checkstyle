package ;

import checkstyle.checks.OverrideCheck;

class OverrideCheckTest extends CheckTestCase {

	public function testCorrectOverride() {
		var msg = checkMessage(OverrideTests.TEST1, new OverrideCheck());
		assertEquals(msg, 'override access modifier should be the at the start of the function for better code readability: test');
	}

	public function testWrongOverride() {
		var msg = checkMessage(OverrideTests.TEST2, new OverrideCheck());
		assertEquals(msg, '');
	}
}

class OverrideTests {
	public static inline var TEST1:String = "
	class Test {
		public override function test() {}
	}";

	public static inline var TEST2:String =
	"class Test {
		override public function test() {}
	}";
}