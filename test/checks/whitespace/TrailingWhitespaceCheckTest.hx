package checks.whitespace;

import checkstyle.checks.whitespace.TrailingWhitespaceCheck;

class TrailingWhitespaceCheckTest extends CheckTestCase {

	public function test() {
		assertMsg(new TrailingWhitespaceCheck(), TrailingWhitespaceTests.TEST1, 'Trailing whitespace');
	}
}

class TrailingWhitespaceTests {
	public static inline var TEST1:String = "
	class Test {
		public function test() {} 
	}";
}