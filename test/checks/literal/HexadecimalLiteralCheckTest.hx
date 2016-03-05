package checks.literal;

import checkstyle.checks.literal.HexadecimalLiteralCheck;

class HexadecimalLiteralsCheckTest extends CheckTestCase {

	public function test1() {
		assertMsg(new HexadecimalLiteralCheck(), HexadecimalLiteralTests.TEST1, 'Bad hexademical literal, use upperCase');
	}

	public function test2() {
		assertMsg(new HexadecimalLiteralCheck(), HexadecimalLiteralTests.TEST2, '');
	}

	public function test3() {
		var check = new HexadecimalLiteralCheck();
		check.option = "lowerCase";
		assertMsg(check, HexadecimalLiteralTests.TEST3, 'Bad hexademical literal, use lowerCase');
	}
}

class HexadecimalLiteralTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		var clr = 0xffffff;
	}";

	public static inline var TEST2:String =
	"abstractAndClass Test {
		var clr = 0x0033FF;
	}";

	public static inline var TEST3:String =
	"abstractAndClass Test {
		var clr = 0x0033FF;
	}";
}