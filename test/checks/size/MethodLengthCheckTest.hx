package checks.size;

import checkstyle.checks.size.MethodLengthCheck;

class MethodLengthCheckTest extends CheckTestCase<MethodLengthCheckTests> {

	public function testWrongMethodLength() {
		assertMsg(new MethodLengthCheck(), TEST1, 'Function is too long: test (> 50 lines, try splitting into multiple functions)');
	}

	public function testCorrectMethodLength() {
		assertNoMsg(new MethodLengthCheck(), TEST2);
	}

	@SupressWarnings('checkstyle:MagicNumber')
	public function testConfigurableMethodLength() {
		var check = new MethodLengthCheck();
		check.max = 10;

		assertMsg(check, TEST3, 'Function is too long: test (> 10 lines, try splitting into multiple functions)');
	}
}

@:enum
abstract MethodLengthCheckTests(String) to String {
	var TEST1 = "
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

	var TEST2 =
	"abstractAndClass Test {
		public function test() {
			tarce('TEST');

			tarce('TEST');

			tarce('TEST');
		}
	}";

	var TEST3 =
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