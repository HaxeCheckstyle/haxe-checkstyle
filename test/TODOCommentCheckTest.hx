import checkstyle.checks.TODOCommentCheck;

class TODOCommentCheckTest extends CheckTestCase {

	public function testTODO() {
		var msg = checkMessage(TODOTests.TEST1, new TODOCommentCheck());
		assertEquals(msg, 'TODO comment: TODO: remove test');
	}
}

class TODOTests {
	public static inline var TEST1:String = "
	class Test {
		// TODO: remove test
		public override function test() {}
	}";
}