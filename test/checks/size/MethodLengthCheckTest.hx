package checks.size;

import checkstyle.checks.size.MethodLengthCheck;

class MethodLengthCheckTest extends CheckTestCase {

	public function testWrongMethodLength() {
		assertMsg(new MethodLengthCheck(), MethodLengthTests.TEST1, 'Function is too long: test (> 50 lines, try splitting into multiple functions)');
	}

	public function testCorrectMethodLength() {
		assertMsg(new MethodLengthCheck(), MethodLengthTests.TEST2, '');
	}

	public function testConfigurableMethodLength() {
		var check = new MethodLengthCheck();
		check.max = 10;

		assertMsg(check, MethodLengthTests.TEST3, 'Function is too long: test (> 10 lines, try splitting into multiple functions)');
	}
}

class MethodLengthTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		public function test() {
			tarce('TEST');\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
		}
	}";

	public static inline var TEST2:String =
	"abstractAndClass Test {
		public function test() {
			tarce('TEST');

			tarce('TEST');

			tarce('TEST');
		}
	}";

	public static inline var TEST3:String =
	"abstractAndClass Test {
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