package checks.comments;

import checkstyle.SeverityLevel;
import checkstyle.checks.comments.TODOCommentCheck;

class TODOCommentCheckTest extends CheckTestCase<TODOCommentCheckTests> {
	@Test
	public function testTODO() {
		var check = new TODOCommentCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST1, "TODO comment: TODO: remove test");
	}

	@Test
	public function testFIXME() {
		var check = new TODOCommentCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST2, "TODO comment: FIXME remove test");
	}

	@Test
	public function testHACK() {
		var check = new TODOCommentCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST3, "TODO comment: HACK remove test");
	}

	@Test
	public function testBUG() {
		var check = new TODOCommentCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST4, "TODO comment: BUG #171: remove test");
	}

	@Test
	public function testXXX() {
		var check = new TODOCommentCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST5, "TODO comment: XXX remove test");
	}

	@Test
	public function testString() {
		var check = new TODOCommentCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TEST6);
	}

	@Test
	public function testInsideComment() {
		var check = new TODOCommentCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TEST7);
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
	var TEST6 = "
	class Test {
		var a:String = 'TODO: remove test';
		public override function test() {}
	}";
	var TEST7 = "
	class Test {
		function test() {
			//trace('TODO');
			//trace('FIXME');
			//trace('BUG:');
			//Test TODO:;
		}
	}";
}