package checks.size;

import checkstyle.checks.size.LineLengthCheck;

class LineLengthCheckTest extends CheckTestCase<LineLengthCheckTests> {

	public function testDefaultLineLength() {
		var check = new LineLengthCheck();
		assertMsg(new LineLengthCheck(), TEST1, "Too long line - 178, max length allowed is " + check.max);
	}

	public function testCorrectLineLength() {
		assertNoMsg(new LineLengthCheck(), TEST2);
	}

	public function testConfigurableLineLength() {
		var check = new LineLengthCheck();
		check.max = 40;
		assertMsg(check, TEST3, "Too long line - 73, max length allowed is " + check.max);
	}
}

@:enum
abstract LineLengthCheckTests(String) to String {
	var TEST1 = "
	class Test {
		var _a:Int;
		public function new() {
			var s = 'LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST';
		}
	}";

	var TEST2 =
	"class Test {
		public function new() {
			var b:Int;
		}

		@SuppressWarnings('checkstyle:LineLength')
		public function newi(param1:Int, param2:Int, param3:Int, param4:Int, param5:Int, param6:Int, param7:Int, param8:Int) {
			_a = 10;
			if (_a > 200 && _a < 250 && _a != 240 && _a != 250 && _a != 260 && _a != 270 && _a != 280 && _a != 290) {
				_a = -1;
			}
		}
	}";

	var TEST3 =
	"class Test {
		public function new() {
			var s = 'LONG LINE TEST LONG LINE TEST LONG LINE TEST LONG LINE TEST';
		}
	}";
}
