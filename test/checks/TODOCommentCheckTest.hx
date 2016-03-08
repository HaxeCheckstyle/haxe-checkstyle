package checks;

import checkstyle.checks.TODOCommentCheck;

class TODOCommentCheckTest extends CheckTestCase<TODOCommentCheckTests> {

	public function testTODO() {
		assertMsg(new TODOCommentCheck(), TEST1, 'TODO comment: TODO: remove test');
	}
}

@:enum
abstract TODOCommentCheckTests(String) to String {
	var TEST1 = "
	class Test {
		// TODO: remove test
		public override function test() {}
	}";
}