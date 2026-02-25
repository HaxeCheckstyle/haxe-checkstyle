package checkstyle.checks.coding;

class LongNumberCheckTest extends CheckTestCase<LongNumberCheckTests> {
	@Test
	public function test() {
		var check = new LongNumberCheck();
		assertNoMsg(check, TEST_STANDARD_NUMBERS);
		assertMessages(check, TEST_LONG_NUMBERS, [
			"\"10123\" is a long number, use _ as a separator",
			"\"20123\" is a long number, use _ as a separator",
			"\"30123\" is a long number, use _ as a separator",
			"\"40123\" is a long number, use _ as a separator",
			"\"50123\" is a long number, use _ as a separator",
			"\"10.123456\" is a long number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_FIXED_LONG_NUMBERS);
		assertNoMsg(check, TEST_HEXADECIMAL);
		assertNoMsg(check, TEST_BINARY);
	}

	@Test
	public function testIgnore() {
		var check = new LongNumberCheck();
		check.ignoreNumbers = [10_123, 30_123, 10.123_456];

		assertNoMsg(check, TEST_STANDARD_NUMBERS);
		assertMessages(check, TEST_LONG_NUMBERS, [
			"\"20123\" is a long number, use _ as a separator",
			"\"40123\" is a long number, use _ as a separator",
			"\"50123\" is a long number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_FIXED_LONG_NUMBERS);
		assertNoMsg(check, TEST_HEXADECIMAL);
		assertNoMsg(check, TEST_BINARY);
	}

	@Test
	public function testHexadecimal() {
		var check = new LongNumberCheck();
		check.checkHexadecimal = true;

		assertNoMsg(check, TEST_STANDARD_NUMBERS);
		assertMessages(check, TEST_LONG_NUMBERS, [
			"\"10123\" is a long number, use _ as a separator",
			"\"20123\" is a long number, use _ as a separator",
			"\"30123\" is a long number, use _ as a separator",
			"\"40123\" is a long number, use _ as a separator",
			"\"50123\" is a long number, use _ as a separator",
			"\"10.123456\" is a long number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_FIXED_LONG_NUMBERS);
		assertMessages(check, TEST_HEXADECIMAL, [
			"\"0x123456\" is a long number, use _ as a separator",
			"\"0x10233023\" is a long number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_BINARY);
	}

	@Test
	public function testBinary() {
		var check = new LongNumberCheck();
		check.checkBinary = true;

		assertNoMsg(check, TEST_STANDARD_NUMBERS);
		assertMessages(check, TEST_LONG_NUMBERS, [
			"\"10123\" is a long number, use _ as a separator",
			"\"20123\" is a long number, use _ as a separator",
			"\"30123\" is a long number, use _ as a separator",
			"\"40123\" is a long number, use _ as a separator",
			"\"50123\" is a long number, use _ as a separator",
			"\"10.123456\" is a long number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_FIXED_LONG_NUMBERS);
		assertNoMsg(check, TEST_HEXADECIMAL);
		assertMessages(check, TEST_BINARY, [
			"\"0b101010\" is a long number, use _ as a separator",
			"\"0b10010001\" is a long number, use _ as a separator"
		]);
	}
}

enum abstract LongNumberCheckTests(String) to String {
	var TEST_STANDARD_NUMBERS = "
	abstractAndClass Test {
		public function new() {
			var a = 10;
			var b = 20;
			var c = 30;
			var d = 40;
			var d = 50;

			var e = 10.123;
		}
	}";
	var TEST_LONG_NUMBERS = "
	abstractAndClass Test {
		public function new() {
			var a = 10123;
			var b = 20123;
			var c = 30123;
			var d = 40123;
			var d = 50123;

			var e = 10.123456;
		}
	}";
	var TEST_FIXED_LONG_NUMBERS = "
	abstractAndClass Test {
		public function new() {
			var a = 10_123;
			var b = 20_123;
			var c = 30_123;
			var d = 40_123;
			var d = 50_123;

			var e = 10.123_456;
			var f = 10.12_34_56;
		}
	}";
	var TEST_HEXADECIMAL = "
	abstractAndClass Test {
		public function new() {
			var a = 0x123;
			var b = 0x123456;
			var c = 0x10233023;
		}
	}";
	var TEST_BINARY = "
	abstractAndClass Test {
		public function new() {
			var a = 0b101;
			var b = 0b101010;
			var c = 0b10010001;
		}
	}";
}
