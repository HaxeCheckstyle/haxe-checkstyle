package checks;

import checkstyle.checks.HexadecimalLiteralsCheck;

class HexadecimalLiteralsCheckTest extends CheckTestCase {

	public function test1() {
		assertMsg(new HexadecimalLiteralsCheck(), HexadecimalTests.TEST1, 'Bad hexademical literal, use upperCase');
	}

	public function test2() {
		assertMsg(new HexadecimalLiteralsCheck(), HexadecimalTests.TEST2, '');
	}

	public function test3() {
		var check = new HexadecimalLiteralsCheck();
		check.option = "lowerCase";
		assertMsg(check, HexadecimalTests.TEST3, 'Bad hexademical literal, use lowerCase');
	}
}

class HexadecimalTests {
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