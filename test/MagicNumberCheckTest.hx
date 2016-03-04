package;

import checkstyle.checks.MagicNumberCheck;

class MagicNumberCheckTest extends CheckTestCase {

	public function testNoMagicNumber() {
		var check = new MagicNumberCheck();
		check.severity = "INFO";
		assertMsg(check, MagicNumberCheckTests.STANDARD_MAGIC_NUMBERS, '');
		assertMsg(check, MagicNumberCheckTests.ALLOWED_MAGIC_NUMBER, '');
	}

	public function testMagicNumber() {
		var check = new MagicNumberCheck();
		check.severity = "INFO";
		assertMsg(check, MagicNumberCheckTests.INT_NUMBER_ASSIGN, 'Magic number "5" detected - consider using a constant');
		assertMsg(check, MagicNumberCheckTests.NEGATIVE_INT_NUMBER_ASSIGN, 'Magic number "-2" detected - consider using a constant');
		assertMsg(check, MagicNumberCheckTests.FLOAT_NUMBER_ASSIGN, 'Magic number "5.0" detected - consider using a constant');
		assertMsg(check, MagicNumberCheckTests.INT_NUMBER_IF, 'Magic number "5" detected - consider using a constant');
		assertMsg(check, MagicNumberCheckTests.INT_NUMBER_FUNCTION, 'Magic number "10" detected - consider using a constant');
	}

	public function testIgnoreNumbers() {
		var check = new MagicNumberCheck();
		check.severity = "INFO";
		check.ignoreNumbers = [-1, 0, 2];
		assertMsg(check, MagicNumberCheckTests.STANDARD_MAGIC_NUMBERS, 'Magic number "1" detected - consider using a constant');

		check.ignoreNumbers = [1, 0, 2];
		assertMsg(check, MagicNumberCheckTests.STANDARD_MAGIC_NUMBERS, 'Magic number "-1" detected - consider using a constant');

		check.ignoreNumbers = [-1, 0, 1, 2, 5];
		assertMsg(check, MagicNumberCheckTests.STANDARD_MAGIC_NUMBERS, '');
		assertMsg(check, MagicNumberCheckTests.ALLOWED_MAGIC_NUMBER, '');
		assertMsg(check, MagicNumberCheckTests.INT_NUMBER_ASSIGN, '');
		assertMsg(check, MagicNumberCheckTests.FLOAT_NUMBER_ASSIGN, '');
		assertMsg(check, MagicNumberCheckTests.INT_NUMBER_IF, '');
		assertMsg(check, MagicNumberCheckTests.INT_NUMBER_FUNCTION, 'Magic number "10" detected - consider using a constant');
	}
}

class MagicNumberCheckTests {
	public static inline var STANDARD_MAGIC_NUMBERS:String = "
	abstractAndClass Test {
		public function new() {
			a = -1;
			b = 0;
			c = 1;
			d = 2;
		}
	}";

	public static inline var INT_NUMBER_ASSIGN:String = "
	abstractAndClass Test {
		public function new() {
			a = 5;
		}
	}";

	public static inline var NEGATIVE_INT_NUMBER_ASSIGN:String = "
	abstractAndClass Test {
		public function new() {
			a = -2;
		}
	}";

	public static inline var FLOAT_NUMBER_ASSIGN:String = "
	abstractAndClass Test {
		public function new() {
			a = 5.0;
		}
	}";

	public static inline var INT_NUMBER_IF:String = "
	abstractAndClass Test {
		public function new() {
			if (a > 5) return;
		}
	}";

	public static inline var INT_NUMBER_FUNCTION:String = "
	abstractAndClass Test {
		public function new(a:Int = 10) {
		}
	}";

	public static inline var ALLOWED_MAGIC_NUMBER:String = "
	abstractAndClass Test {
		static inline var VAL = 5;
		public function new() {
			a = VAL;
		}
	}";
}