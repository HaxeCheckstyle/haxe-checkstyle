package checkstyle.checks.coding;

class LongNumberCheckTest extends CheckTestCase<LongNumberCheckTests> {
	@Test
	public function test() {
		var check = new LongNumberCheck();

		assertNoMsg(check, TEST_DECIMAL);
		assertMessages(check, TEST_DECIMAL_LONG, [
			"\"1012\" is a long number, use _ as a separator",
			"\"20123\" is a long number, use _ as a separator",
			"\"3012\" is a long number, use _ as a separator",
			"\"40123\" is a long number, use _ as a separator",
			"\"50123\" is a long number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_DECIMAL_FIXED);

		assertNoMsg(check, TEST_HEXADECIMAL);
		assertMessages(check, TEST_HEXADECIMAL_LONG, [
			"\"0x1234_5678\" uses separators improperly, use _ every 8 digits"
		]);
		assertNoMsg(check, TEST_HEXADECIMAL_FIXED);

		assertNoMsg(check, TEST_BINARY);
		assertMessages(check, TEST_BINARY_LONG, [
			"\"0b1001_0001\" uses separators improperly, use _ every 8 digits",
			"\"0b1001000101\" is a long binary number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_BINARY_FIXED);
	}

	@Test
	public function testDecimalGroupSize() {
		var check = new LongNumberCheck();
		check.decimalGroupSize = 4;

		assertNoMsg(check, TEST_DECIMAL);
		assertMessages(check, TEST_DECIMAL_LONG, [
			"\"20123\" is a long number, use _ as a separator",
			"\"40123\" is a long number, use _ as a separator",
			"\"50123\" is a long number, use _ as a separator"
		]);
		assertMessages(check, TEST_DECIMAL_FIXED, [
			"\"1_012\" uses separators improperly, use _ every 4 digits",
			"\"20_123\" uses separators improperly, use _ every 4 digits",
			"\"3_012\" uses separators improperly, use _ every 4 digits",
			"\"40_123\" uses separators improperly, use _ every 4 digits",
			"\"50_123\" uses separators improperly, use _ every 4 digits"
		]);
		
		assertNoMsg(check, TEST_HEXADECIMAL);
		assertMessages(check, TEST_HEXADECIMAL_LONG, [
			"\"0x1234_5678\" uses separators improperly, use _ every 8 digits"
		]);
		assertNoMsg(check, TEST_HEXADECIMAL_FIXED);

		assertNoMsg(check, TEST_BINARY);
		assertMessages(check, TEST_BINARY_LONG, [
			"\"0b1001_0001\" uses separators improperly, use _ every 8 digits",
			"\"0b1001000101\" is a long binary number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_BINARY_FIXED);
	}

	@Test
	public function testFractionalGroupSize() {
		var check = new LongNumberCheck();
		check.decimalGroupSize = 3;
		check.fractionalGroupSize = 3;

		assertNoMsg(check, TEST_DECIMAL);
		assertMessages(check, TEST_DECIMAL_LONG, [
			"\"1012\" is a long number, use _ as a separator",
			"\"20123\" is a long number, use _ as a separator",
			"\"3012\" is a long number, use _ as a separator",
			"\"40123\" is a long number, use _ as a separator",
			"\"50123\" is a long number, use _ as a separator",
			"\"10.123456\" is a long number, use _ as a separator"
		]);
		assertMsg(check, TEST_DECIMAL_FIXED, "\"10.123456\" is a long number, use _ as a separator");

		assertNoMsg(check, TEST_HEXADECIMAL);
		assertMessages(check, TEST_HEXADECIMAL_LONG, [
			"\"0x1234_5678\" uses separators improperly, use _ every 8 digits"
		]);
		assertNoMsg(check, TEST_HEXADECIMAL_FIXED);

		assertNoMsg(check, TEST_BINARY);
		assertMessages(check, TEST_BINARY_LONG, [
			"\"0b1001_0001\" uses separators improperly, use _ every 8 digits",
			"\"0b1001000101\" is a long binary number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_BINARY_FIXED);
	}

	@Test
	public function testHexadecimalGroupSize() {
		var check = new LongNumberCheck();
		check.decimalGroupSize = -1;
		check.hexadecimalGroupSize = 4;

		assertNoMsg(check, TEST_DECIMAL);
		assertNoMsg(check, TEST_DECIMAL_LONG);
		assertNoMsg(check, TEST_DECIMAL_FIXED);
		assertMessages(check, TEST_HEXADECIMAL, [
			"\"0x123456\" is a long hexadecimal number, use _ as a separator",
			"\"0x10233023\" is a long hexadecimal number, use _ as a separator"
		]);
		assertNoMsg(check, TEST_BINARY);
	}

	@Test
	public function testBinaryGroupSize() {
		var check = new LongNumberCheck();
		check.decimalGroupSize = -1;
		check.binaryGroupSize = 4;

		assertNoMsg(check, TEST_DECIMAL);
		assertNoMsg(check, TEST_DECIMAL_LONG);
		assertNoMsg(check, TEST_DECIMAL_FIXED);
		assertNoMsg(check, TEST_HEXADECIMAL);
		assertMessages(check, TEST_BINARY, [
			"\"0b101010\" is a long binary number, use _ as a separator",
			"\"0b10010001\" is a long binary number, use _ as a separator"
		]);
		assertMessages(check, TEST_BINARY_LONG, [
			"\"0b1001000101\" is a long binary number, use _ as a separator"
		]);
		assertMessages(check, TEST_BINARY_FIXED, [
			"\"0b10_01000101\" uses separators improperly, use _ every 4 digits"
		]);
	}

	@Test
	public function testMinimum() {
		var check = new LongNumberCheck();
		check.decimalGroupSize = 3;
		check.hexadecimalGroupSize = 4;
		check.binaryGroupSize = 4;
		check.decimalMinimum = 1_000_000;
		check.hexadecimalMinimum = 0x100_0000;

		assertNoMsg(check, TEST_DECIMAL);
		assertNoMsg(check, TEST_DECIMAL_LONG);
		assertNoMsg(check, TEST_DECIMAL_FIXED);
		assertMessages(check, TEST_HEXADECIMAL, [
			// Not long enough
			// "\"0x123456\" is a long hexadecimal number, use _ as a separator",
			// Long enough
			"\"0x10233023\" is a long hexadecimal number, use _ as a separator"
		]);
	}
}

enum abstract LongNumberCheckTests(String) to String {
	var TEST_DECIMAL = "
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
	var TEST_DECIMAL_LONG = "
	abstractAndClass Test {
		public function new() {
			var a = 1012;
			var b = 20123;
			var c = 3012;
			var d = 40123;
			var d = 50123;

			var e = 10.123456;
		}
	}";
	var TEST_DECIMAL_FIXED = "
	abstractAndClass Test {
		public function new() {
			var a = 1_012;
			var b = 20_123;
			var c = 3_012;
			var d = 40_123;
			var d = 50_123;

			var e = 10.123456;
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
	var TEST_HEXADECIMAL_LONG = "
	abstractAndClass Test {
		public function new() {
			var c = 0x1234_5678;
			var c = 0x10233023;
		}
	}";
	var TEST_HEXADECIMAL_FIXED = "
	abstractAndClass Test {
		public function new() {
			var c = 0x12345678;
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
	var TEST_BINARY_LONG = "
	abstractAndClass Test {
		public function new() {
			var c = 0b1001_0001;
			var c = 0b1001000101;
		}
	}";
	var TEST_BINARY_FIXED = "
	abstractAndClass Test {
		public function new() {
			var c = 0b10_01000101;
		}
	}";
}
