package checks.whitespace;

import checkstyle.CheckMessage.SeverityLevel;
import checkstyle.checks.whitespace.TrailingWhitespaceCheck;

class TrailingWhitespaceCheckTest extends CheckTestCase<TrailingWhitespaceCheckTests> {

	public function test() {
		var check = new TrailingWhitespaceCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST1, "Trailing whitespace");
	}
}

@:enum
abstract TrailingWhitespaceCheckTests(String) to String {
	var TEST1 = "
	class Test {
		public function test() {} 
	}";
}