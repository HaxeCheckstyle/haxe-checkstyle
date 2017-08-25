package checks.size;

import checkstyle.checks.size.MethodLengthCheck;

class MethodLengthCheckTest extends CheckTestCase<MethodLengthCheckTests> {

	public function testWrongMethodLength() {
		assertMsg(new MethodLengthCheck(), TEST1, "Method `test` length is 354 lines (max allowed is 50)");
	}

	public function testCorrectMethodLength() {
		assertNoMsg(new MethodLengthCheck(), TEST2);
	}

	public function testConfigurableMethodLength() {
		var check = new MethodLengthCheck();
		check.max = 10;

		assertMsg(check, TEST3, "Method `test` length is 14 lines (max allowed is 10)");
	}

	public function testIgnoreEmptyLines() {
		var check = new MethodLengthCheck();
		check.max = 10;
		check.countEmpty = true;

		assertNoMsg(check, TEST3);

		check.countEmpty = false;
		assertMsg(check, TEST3, "Method `test` length is 14 lines (max allowed is 10)");
	}
}

@:enum
abstract MethodLengthCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		public function test() {
			trace('TEST');\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
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
			trace('TEST');

			trace('TEST');

			trace('TEST');
		}
	}";

	var TEST3 =
	"abstractAndClass Test {
		public function test() {
			trace('TEST');

			trace('TEST');

			trace('TEST');

			trace('TEST');

			trace('TEST');

			trace('TEST');

			// comment
		}

		@SuppressWarnings('checkstyle:MethodLength')
		public function test1() {
			trace('TEST');

			trace('TEST');

			trace('TEST');

			trace('TEST');

			trace('TEST');

			trace('TEST');
		}
	}";
}