package checks.whitespace;

import checkstyle.checks.whitespace.TrailingWhitespaceCheck;

class TrailingWhitespaceCheckTest extends CheckTestCase<TrailingWhitespaceCheckTests> {

	public function test() {
		assertMsg(new TrailingWhitespaceCheck(), TEST1, 'Trailing whitespace');
	}
}

@:enum
abstract TrailingWhitespaceCheckTests(String) to String {
	var TEST1 = "
	class Test {
		public function test() {} 
	}";
}