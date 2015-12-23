package ;

import checkstyle.checks.whitespace.EmptyLinesCheck;

class EmptyLinesCheckTest extends CheckTestCase {

	public function testDefaultEmptyLines() {
		var msg = checkMessage(EmptyLinesTests.TEST1, new EmptyLinesCheck());
		assertEquals(msg, 'Too many consecutive empty lines (> 1)');
	}

	public function testCorrectEmptyLines() {
		var msg = checkMessage(EmptyLinesTests.TEST2, new EmptyLinesCheck());
		assertEquals(msg, '');
	}

	public function testConfigurableEmptyLines() {
		var check = new EmptyLinesCheck();
		check.max = 2;

		var msg = checkMessage(EmptyLinesTests.TEST3, check);
		assertEquals(msg, '');
	}
}

class EmptyLinesTests {
	public static inline var TEST1:String = "
	class Test {
		var _a:Int;


	}";

	public static inline var TEST2:String =
	"class Test {
		public function new() {
			var b:Int;

		}
	}";

	public static inline var TEST3:String =
	"class Test {
		public function new() {
			var b:Int;


		}
	}";
}