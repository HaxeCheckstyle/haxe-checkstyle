package ;

import checkstyle.checks.TrailingWhitespaceCheck;

class TrailingWhiteSpacecheckTest extends CheckTestCase {

	public function test() {
		var msg = checkMessage(TrailingWhiteSpaceTests.TEST1, new TrailingWhitespaceCheck());
		assertEquals(msg, 'Trailing whitespace');
	}
}

class TrailingWhiteSpaceTests {
	public static inline var TEST1:String = "
	class Test {
		public function test() {} 
	}";
}