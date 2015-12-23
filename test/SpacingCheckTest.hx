package ;

import checkstyle.checks.whitespace.SpacingCheck;

class SpacingCheckTest extends CheckTestCase {

	public function testIf() {
		var msg = checkMessage(SpacingTests.TEST1, new SpacingCheck());
		assertEquals(msg, 'No space between if and condition');
	}

	public function testBinaryOperator() {
		var msg = checkMessage(SpacingTests.TEST2, new SpacingCheck());
		assertEquals(msg, 'No space around +');
	}

	public function testUnaryOperator() {
		var msg = checkMessage(SpacingTests.TEST3, new SpacingCheck());
		assertEquals(msg, 'Space around ++');
	}

	public function testFor() {
		var msg = checkMessage(SpacingTests.TEST4, new SpacingCheck());
		assertEquals(msg, '');
	}
}

class SpacingTests {
	public static inline var TEST1:String = "
	class Test {
		public function test() {
			if(true) {}
		}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function test() {
			var a = a+1;
		}
	}";

	public static inline var TEST3:String =
"class Test {
		public function test() {
			var a = a ++;
		}
	}";

	public static inline var TEST4:String =
	"class Test {
		public function test() {
			for(i in 0...10) {
			
			}
		}
	}";
}