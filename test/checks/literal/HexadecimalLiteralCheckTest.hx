package checks.literal;

import checkstyle.checks.literal.HexadecimalLiteralCheck;

class HexadecimalLiteralCheckTest extends CheckTestCase<HexadecimalLiteralCheckTests> {

	@Test
	public function test1() {
		assertMsg(new HexadecimalLiteralCheck(), TEST1, "Bad hexadecimal literal, use upperCase");
	}

	@Test
	public function test2() {
		assertNoMsg(new HexadecimalLiteralCheck(), TEST2);
	}

	@Test
	public function test3() {
		var check = new HexadecimalLiteralCheck();
		check.option = "lowerCase";
		assertMsg(check, TEST3, "Bad hexadecimal literal, use lowerCase");
	}
}

@:enum
abstract HexadecimalLiteralCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var clr = 0xffffff;
	}";

	var TEST2 =
	"abstractAndClass Test {
		var clr = 0x0033FF;
	}";

	var TEST3 =
	"abstractAndClass Test {
		var clr = 0x0033FF;
	}";
}