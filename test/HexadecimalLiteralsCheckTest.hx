package ;

import checkstyle.checks.HexadecimalLiteralsCheck;

class HexadecimalLiteralsCheckTest extends CheckTestCase {

	public function testCorrectOverride() {
		var msg = checkMessage(HexadecimalTests.TEST1, new HexadecimalLiteralsCheck());
		assertEquals(msg, 'Bad hexademical literal, use uppercase');
	}

	public function testWrongOverride() {
		var msg = checkMessage(HexadecimalTests.TEST2, new HexadecimalLiteralsCheck());
		assertEquals(msg, '');
	}
}

class HexadecimalTests {
	public static inline var TEST1:String = "
	class Test {
		var _clr = 0xffffff;
	}";

	public static inline var TEST2:String =
	"class Test {
		var _clr = 0x0033FF;
	}";
}