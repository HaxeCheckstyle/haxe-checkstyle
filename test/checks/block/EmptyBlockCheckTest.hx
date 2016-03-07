package checks.block;

import checkstyle.checks.block.EmptyBlockCheck;

class EmptyBlockCheckTest extends CheckTestCase {

	static inline var MSG_EMPTY_BLOCK:String = 'Empty block should be written as {}';
	static inline var MSG_EMPTY_BLOCK_SHOULD_CONTAIN:String = 'Empty block should contain a comment or a statement';
	static inline var MSG_EMPTY_BLOCK_CONTAIN_STATEMENT:String = 'Empty block should contain a statement';
	static inline var MSG_BLOCK_SHOULD_CONTAIN:String = 'Block should contain a statement';

	public function testCorrectEmptyBlock() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertNoMsg(check, EmptyBlockTests.EMPTY_BLOCK);
		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT);
		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT2);
		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_COMMENT);
		assertNoMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL);
		assertNoMsg(check, EmptyBlockTests.OBJECT_DECL_WITH_COMMENT);
	}

	public function testWrongEmptyBlock() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK_WHITESPACE, MSG_EMPTY_BLOCK);
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL_WHITESPACE, MSG_EMPTY_BLOCK);
	}

	public function testEmptyBlockComment() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = TEXT;

		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT);
		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT2);
		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_COMMENT);
		assertNoMsg(check, EmptyBlockTests.OBJECT_DECL_WITH_COMMENT);

		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK, MSG_EMPTY_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL, MSG_EMPTY_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK_WHITESPACE, MSG_EMPTY_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL_WHITESPACE, MSG_EMPTY_BLOCK_SHOULD_CONTAIN);
	}

	public function testEmptyBlockStatement() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = STATEMENT;

		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT);
		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT2);

		assertMsg(check, EmptyBlockTests.BLOCK_WITH_COMMENT, MSG_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EmptyBlockTests.OBJECT_DECL_WITH_COMMENT, MSG_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK_WHITESPACE, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL_WHITESPACE, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
	}

	public function testEmptyBlockStatementObjectDecl() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = STATEMENT;
		check.tokens = [OBJECT_DECL];

		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT);
		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT2);
		assertNoMsg(check, EmptyBlockTests.BLOCK_WITH_COMMENT);
		assertNoMsg(check, EmptyBlockTests.EMPTY_BLOCK);
		assertNoMsg(check, EmptyBlockTests.EMPTY_BLOCK_WHITESPACE);

		assertMsg(check, EmptyBlockTests.OBJECT_DECL_WITH_COMMENT, MSG_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL_WHITESPACE, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
	}
}

class EmptyBlockTests {
	public static inline var EMPTY_BLOCK:String = "
	class Test {
		public function new() {}
		@SuppressWarnings('checkstyle:EmptyBlock')
		public function test() {
		}
	}";

	public static inline var EMPTY_BLOCK_WHITESPACE:String = "
	class Test {
		public function new(){

		}
	}";

	public static inline var BLOCK_WITH_STATEMENT:String =
	"class Test {
		public function new() { var a:Int;

		}
	}";

	public static inline var BLOCK_WITH_STATEMENT2:String =
	"class Test {
		public function new() {
			var a:Int; }
	}";

	public static inline var BLOCK_WITH_COMMENT:String =
	"class Test {
		public function new() {
			// comment
		}
	}";

	public static inline var EMPTY_OBJECT_DECL:String =
	"class Test {
		public function new() {
			var a = {};
		}
	}";

	public static inline var EMPTY_OBJECT_DECL_WHITESPACE:String = "
	class Test {
		public function new() {
			var a = {
			};
		}
	}";

	public static inline var OBJECT_DECL_WITH_COMMENT:String = "
	class Test {
		public function new() {
			var a = {
				// comment
			};
		}
	}";

	public static inline var OBJECT_DECL_WITH_COMMENT2:String = "
	class Test {
		public function new() { /* comment
								 */
			var a = { // comment
			};
		}
	}";
}