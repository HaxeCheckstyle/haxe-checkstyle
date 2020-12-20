package checkstyle.checks.whitespace;

import checkstyle.SeverityLevel;

class TrailingWhitespaceCheckTest extends CheckTestCase<TrailingWhitespaceCheckTests> {
	@Test
	public function test() {
		var check = new TrailingWhitespaceCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST1, "Trailing whitespace");
	}
}

enum abstract TrailingWhitespaceCheckTests(String) to String {
	var TEST1 = "
	class Test {
		public function test() {} " + "
	}";
}