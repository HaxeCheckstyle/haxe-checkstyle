package checks.block;

import checkstyle.checks.block.EmptyBlockCheck;

class EmptyBlockCheckTest extends CheckTestCase {

	public function testCorrectEmptyBlock() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK, '');
		assertMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT, '');
		assertMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT2, '');
		assertMsg(check, EmptyBlockTests.BLOCK_WITH_COMMENT, '');
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL, '');
		assertMsg(check, EmptyBlockTests.OBJECT_DECL_WITH_COMMENT, '');
	}

	public function testWrongEmptyBlock() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK_WHITESPACE, 'Empty block should be written as {}');
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL_WHITESPACE, 'Empty block should be written as {}');
	}

	public function testEmptyBlockComment() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = EmptyBlockCheck.TEXT;

		assertMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT, '');
		assertMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT2, '');
		assertMsg(check, EmptyBlockTests.BLOCK_WITH_COMMENT, '');
		assertMsg(check, EmptyBlockTests.OBJECT_DECL_WITH_COMMENT, '');

		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK, 'Empty block should contain a comment or a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL, 'Empty block should contain a comment or a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK_WHITESPACE, 'Empty block should contain a comment or a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL_WHITESPACE, 'Empty block should contain a comment or a statement');
	}

	public function testEmptyBlockStatement() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = EmptyBlockCheck.STATEMENT;

		assertMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT, '');
		assertMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT2, '');

		assertMsg(check, EmptyBlockTests.BLOCK_WITH_COMMENT, 'Block should contain a statement');
		assertMsg(check, EmptyBlockTests.OBJECT_DECL_WITH_COMMENT, 'Block should contain a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK, 'Empty block should contain a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL, 'Empty block should contain a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK_WHITESPACE, 'Empty block should contain a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL_WHITESPACE, 'Empty block should contain a statement');
	}

	public function testEmptyBlockStatementObjectDecl() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = EmptyBlockCheck.STATEMENT;
		check.tokens = ["OBJECT_DECL"];

		assertMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT, '');
		assertMsg(check, EmptyBlockTests.BLOCK_WITH_STATEMENT2, '');
		assertMsg(check, EmptyBlockTests.BLOCK_WITH_COMMENT, '');
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK, '');
		assertMsg(check, EmptyBlockTests.EMPTY_BLOCK_WHITESPACE, '');

		assertMsg(check, EmptyBlockTests.OBJECT_DECL_WITH_COMMENT, 'Block should contain a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL, 'Empty block should contain a statement');
		assertMsg(check, EmptyBlockTests.EMPTY_OBJECT_DECL_WHITESPACE, 'Empty block should contain a statement');
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