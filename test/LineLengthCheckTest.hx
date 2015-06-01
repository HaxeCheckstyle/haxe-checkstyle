package ;

import checkstyle.checks.LineLengthCheck;

class LineLengthCheckTest extends CheckTestCase {

	public function testDefaultLineLength() {
		var msg = checkMessage(LineLengthTests.TEST1, new LineLengthCheck());
		assertEquals(msg, 'Too long line (> 200)');
	}

	public function testCorrectLineLength() {
		var msg = checkMessage(LineLengthTests.TEST2, new LineLengthCheck());
		assertEquals(msg, '');
	}

	public function testConfigurableLineLength() {
		var check = new LineLengthCheck();
		check.maxCharacters = 40;

		var msg = checkMessage(LineLengthTests.TEST3, check);
		assertEquals(msg, 'Too long line (> 40)');
	}
}

class LineLengthTests {
	public static inline var TEST1:String = "
	class Test {
		var _a:Int;
		public function new() {
			_a = 10;
			if (_a > 200 && _a < 250 && _a != 240 && _a != 250 && _a != 260 && _a != 270 && _a != 280 && _a != 290 && _a > 200 && _a < 250 && _a != 240 && _a != 250 && _a != 260 && _a != 270 && _a != 280 && _a != 290) {
				_a = -1;
			}
		}
	}";

	public static inline var TEST2:String =
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

	public static inline var TEST3:String =
	"class Test {
		public function new() {
			_a = 10;
			if (_a > 200 && _a < 250 && _a != 240 && _a != 250) {
				_a = -1;
			}
		}
	}";
}