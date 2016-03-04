import checkstyle.checks.whitespace.TrailingWhitespaceCheck;

class TrailingWhitespaceCheckTest extends CheckTestCase {

	public function test() {
		var msg = checkMessage(TrailingWhitespaceTests.TEST1, new TrailingWhitespaceCheck());
		assertEquals(msg, 'Trailing whitespace');
	}
}

class TrailingWhitespaceTests {
	public static inline var TEST1:String = "
	class Test {
		public function test() {} 
	}";
}