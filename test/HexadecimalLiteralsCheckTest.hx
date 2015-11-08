package ;

import checkstyle.checks.HexadecimalLiteralsCheck;

class HexadecimalLiteralsCheckTest extends CheckTestCase {

	public function test1() {
		var msg = checkMessage(HexadecimalTests.TEST1, new HexadecimalLiteralsCheck());
		assertEquals(msg, 'Bad hexademical literal, use upperCase');
	}

	public function test2() {
		var msg = checkMessage(HexadecimalTests.TEST2, new HexadecimalLiteralsCheck());
		assertEquals(msg, '');
	}

	public function test3() {
		var check = new HexadecimalLiteralsCheck();
		check.option = "lowerCase";
		var msg = checkMessage(HexadecimalTests.TEST3, check);
		assertEquals(msg, 'Bad hexademical literal, use lowerCase');
	}
}

class HexadecimalTests {
	public static inline var TEST1:String = "
	class Test {
		var clr = 0xffffff;
	}";

	public static inline var TEST2:String =
	"class Test {
		var clr = 0x0033FF;
	}";

	public static inline var TEST3:String =
	"class Test {
		var clr = 0x0033FF;
	}";
}