package checks;

import checkstyle.checks.TODOCommentCheck;

class TODOCommentCheckTest extends CheckTestCase {

	public function testTODO() {
		assertMsg(new TODOCommentCheck(), TODOTests.TEST1, 'TODO comment: TODO: remove test');
	}
}

class TODOTests {
	public static inline var TEST1:String = "
	class Test {
		// TODO: remove test
		public override function test() {}
	}";
}