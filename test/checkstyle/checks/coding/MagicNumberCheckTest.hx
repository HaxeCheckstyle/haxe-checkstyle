package checkstyle.checks.coding;

class MagicNumberCheckTest extends CheckTestCase<MagicNumberCheckTests> {
	@Test
	public function testNoMagicNumber() {
		var check = new MagicNumberCheck();
		assertNoMsg(check, STANDARD_MAGIC_NUMBERS);
		assertNoMsg(check, ALLOWED_MAGIC_NUMBER);
		assertNoMsg(check, META_NUMBER);
	}

	@Test
	public function testMagicNumber() {
		var check = new MagicNumberCheck();
		assertMsg(check, INT_NUMBER_ASSIGN, '"5" is a magic number');
		assertMsg(check, NEGATIVE_INT_NUMBER_ASSIGN, '"-2" is a magic number');
		assertMsg(check, FLOAT_NUMBER_ASSIGN, '"5.0" is a magic number');
		assertMsg(check, INT_NUMBER_IF, '"5" is a magic number');
		assertMsg(check, INT_NUMBER_FUNCTION, '"10" is a magic number');
	}

	@Test
	public function testIgnoreNumbers() {
		var check = new MagicNumberCheck();
		check.ignoreNumbers = [-1, 0, 2];
		assertMsg(check, STANDARD_MAGIC_NUMBERS, '"1" is a magic number');

		check.ignoreNumbers = [1, 0, 2];
		assertMsg(check, STANDARD_MAGIC_NUMBERS, '"-1" is a magic number');

		check.ignoreNumbers = [-1, 0, 1, 2, 5];
		assertNoMsg(check, STANDARD_MAGIC_NUMBERS);
		assertNoMsg(check, ALLOWED_MAGIC_NUMBER);
		assertNoMsg(check, INT_NUMBER_ASSIGN);
		assertNoMsg(check, FLOAT_NUMBER_ASSIGN);
		assertNoMsg(check, INT_NUMBER_IF);
		assertMsg(check, INT_NUMBER_FUNCTION, '"10" is a magic number');
	}

	@Test
	public function testEnumAbstract() {
		var check = new MagicNumberCheck();
		assertNoMsg(check, ENUM_ABSTRACT);
		assertNoMsg(check, ENUM_ABSTRACT_WITH_CLASS);
		assertNoMsg(check, HAXE4_ENUM_ABSTRACT);
	}

	@Test
	public function testFinal() {
		var check = new MagicNumberCheck();
		assertNoMsg(check, HAXE4_FINAL_VAR);
		assertMsg(check, HAXE4_FINAL_FUNCTION, '"7" is a magic number');
	}
}

enum abstract MagicNumberCheckTests(String) to String {
	var STANDARD_MAGIC_NUMBERS = "
	abstractAndClass Test {
		public function new() {
			a = -1;
			b = 0;
			c = 1;
			d = 2;
		}
	}";
	var INT_NUMBER_ASSIGN = "
	abstractAndClass Test {
		public function new() {
			a = 5;
		}
	}";
	var NEGATIVE_INT_NUMBER_ASSIGN = "
	abstractAndClass Test {
		public function new() {
			a = -2;
		}
	}";
	var FLOAT_NUMBER_ASSIGN = "
	abstractAndClass Test {
		public function new() {
			a = 5.0;
		}
	}";
	var INT_NUMBER_IF = "
	abstractAndClass Test {
		public function new() {
			if (a > 5) return;
		}
	}";
	var INT_NUMBER_FUNCTION = "
	abstractAndClass Test {
		public function new(a:Int = 10) {
		}
	}";
	var ALLOWED_MAGIC_NUMBER = "
	abstractAndClass Test {
		static inline var VAL = 5;
		public function new() {
			a = VAL;
		}
	}";
	var ENUM_ABSTRACT = "
	enum abstract Style(Int) {
		var BOLD = 1;
		var RED = 91;
		var BLUE = 94;
		var MAGENTA = 95;
	}";
	var ENUM_ABSTRACT_WITH_CLASS = "
	enum abstract Style(Int) {
		var BOLD = 1;
		var RED = 91;
		var BLUE = 94;
		var MAGENTA = 95;
	}

	class Test {
		static inline var VAL = 5;
	}
	";
	var HAXE4_ENUM_ABSTRACT = "
	enum abstract Style(Int) {
		var BOLD = 1;
		var RED = 91;
		var BLUE = 94;
		var MAGENTA = 95;
	}";
	var HAXE4_FINAL_VAR = "
	abstractAndClass Test {
		static inline final VAL1 = 5;
		static final VAL2 = 6;
		final VAL3 = 7;
	}";
	var HAXE4_FINAL_FUNCTION = "
	abstractAndClass Test {
		final function test() {
			val = 7;
		}
	}";
	var META_NUMBER = "
	abstractAndClass Test {
		@meta(100)
		function test() {
		}
	}";
}