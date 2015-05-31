package ;

import checkstyle.checks.MethodLengthCheck;

class MethodLengthCheckTest extends CheckTestCase {

	public function testWrongMethodLength() {
		var msg = checkMessage(MethodLengthTests.TEST1, new MethodLengthCheck());
		assertEquals(msg, 'Function is too long: test (> 50 lines, try splitting into multiple functions)');
	}

	public function testCorrectMethodLength() {
		var msg = checkMessage(MethodLengthTests.TEST2, new MethodLengthCheck());
		assertEquals(msg, '');
	}

	public function testConfigurableMethodLength() {
		var check = new MethodLengthCheck();
		check.maxFunctionLines = 10;

		var msg = checkMessage(MethodLengthTests.TEST3, check);
		assertEquals(msg, 'Function is too long: test (> 10 lines, try splitting into multiple functions)');
	}
}

class MethodLengthTests {
	public static inline var TEST1:String = "
	class Test {
		public function test() {
			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');
		}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function test() {
			tarce('TEST');

			tarce('TEST');

			tarce('TEST');
		}
	}";

	public static inline var TEST3:String =
	"class Test {
		public function test() {
			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');
		}

		@SuppressWarnings('checkstyle:MethodLength')
		public function test1() {
			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');

			tarce('TEST');
		}
	}";
}
