package checks.comments;

import checkstyle.checks.comments.TODOCommentCheck;

class TODOCommentCheckTest extends CheckTestCase<TODOCommentCheckTests> {

	public function testTODO() {
		assertMsg(new TODOCommentCheck(), TEST1, "TODO comment: TODO: remove test");
	}

	public function testFIXME() {
		assertMsg(new TODOCommentCheck(), TEST2, "TODO comment: FIXME remove test");
	}

	public function testHACK() {
		assertMsg(new TODOCommentCheck(), TEST3, "TODO comment: HACK remove test");
	}

	public function testBUG() {
		assertMsg(new TODOCommentCheck(), TEST4, "TODO comment: BUG #171: remove test");
	}

	public function testXXX() {
		assertMsg(new TODOCommentCheck(), TEST5, "TODO comment: XXX remove test");
	}
}

@:enum
abstract TODOCommentCheckTests(String) to String {
	var TEST1 = "
	class Test {
		// TODO: remove test
		public override function test() {}
	}";

	var TEST2 = "
	class Test {
		// FIXME remove test
		public override function test() {}
	}";

	var TEST3 = "
	class Test {
		// HACK remove test
		public override function test() {}
	}";

	var TEST4 = "
	class Test {
		// BUG #171: remove test
		public override function test() {}
	}";

	var TEST5 = "
	class Test {
		// XXX remove test
		public override function test() {}
	}";
}