package checks.block;

import checkstyle.checks.block.EmptyBlockCheck;

class EmptyBlockCheckTest extends CheckTestCase<EmptyBlockCheckTests> {

	static inline var MSG_EMPTY_BLOCK:String = 'Empty block should be written as "{}"';
	static inline var MSG_EMPTY_BLOCK_SHOULD_CONTAIN:String = 'Empty block should contain a comment or a statement';
	static inline var MSG_EMPTY_BLOCK_CONTAIN_STATEMENT:String = 'Empty block should contain a statement';
	static inline var MSG_BLOCK_SHOULD_CONTAIN:String = 'Block should contain a statement';

	public function testCorrectEmptyBlock() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertNoMsg(check, EMPTY_BLOCK);
		assertNoMsg(check, BLOCK_WITH_STATEMENT);
		assertNoMsg(check, BLOCK_WITH_STATEMENT2);
		assertNoMsg(check, BLOCK_WITH_COMMENT);
		assertNoMsg(check, EMPTY_OBJECT_DECL);
		assertNoMsg(check, OBJECT_DECL_WITH_COMMENT);
	}

	public function testWrongEmptyBlock() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertMsg(check, EMPTY_BLOCK_WHITESPACE, MSG_EMPTY_BLOCK);
		assertMsg(check, EMPTY_OBJECT_DECL_WHITESPACE, MSG_EMPTY_BLOCK);
	}

	public function testEmptyBlockComment() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = TEXT;

		assertNoMsg(check, BLOCK_WITH_STATEMENT);
		assertNoMsg(check, BLOCK_WITH_STATEMENT2);
		assertNoMsg(check, BLOCK_WITH_COMMENT);
		assertNoMsg(check, OBJECT_DECL_WITH_COMMENT);

		assertMsg(check, EMPTY_BLOCK, MSG_EMPTY_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EMPTY_OBJECT_DECL, MSG_EMPTY_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EMPTY_BLOCK_WHITESPACE, MSG_EMPTY_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EMPTY_OBJECT_DECL_WHITESPACE, MSG_EMPTY_BLOCK_SHOULD_CONTAIN);
	}

	public function testEmptyBlockStatement() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = STATEMENT;

		assertNoMsg(check, BLOCK_WITH_STATEMENT);
		assertNoMsg(check, BLOCK_WITH_STATEMENT2);

		assertMsg(check, BLOCK_WITH_COMMENT, MSG_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, OBJECT_DECL_WITH_COMMENT, MSG_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EMPTY_BLOCK, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
		assertMsg(check, EMPTY_OBJECT_DECL, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
		assertMsg(check, EMPTY_BLOCK_WHITESPACE, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
		assertMsg(check, EMPTY_OBJECT_DECL_WHITESPACE, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
	}

	public function testEmptyBlockStatementObjectDecl() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.option = STATEMENT;
		check.tokens = [OBJECT_DECL];

		assertNoMsg(check, BLOCK_WITH_STATEMENT);
		assertNoMsg(check, BLOCK_WITH_STATEMENT2);
		assertNoMsg(check, BLOCK_WITH_COMMENT);
		assertNoMsg(check, EMPTY_BLOCK);
		assertNoMsg(check, EMPTY_BLOCK_WHITESPACE);

		assertMsg(check, OBJECT_DECL_WITH_COMMENT, MSG_BLOCK_SHOULD_CONTAIN);
		assertMsg(check, EMPTY_OBJECT_DECL, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
		assertMsg(check, EMPTY_OBJECT_DECL_WHITESPACE, MSG_EMPTY_BLOCK_CONTAIN_STATEMENT);
	}

	public function testMacroReificationIssue149() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		check.tokens = [REIFICATION];
		assertNoMsg(check, MACRO_REIFICATION_ISSUE_149);
	}
}

@:enum
abstract EmptyBlockCheckTests(String) to String {
	var EMPTY_BLOCK = "
	class Test {
		public function new() {}
		@SuppressWarnings('checkstyle:EmptyBlock')
		public function test() {
		}
	}";

	var EMPTY_BLOCK_WHITESPACE = "
	class Test {
		public function new(){

		}
	}";

	var BLOCK_WITH_STATEMENT =
	"class Test {
		public function new() { var a:Int;

		}
	}";

	var BLOCK_WITH_STATEMENT2 =
	"class Test {
		public function new() {
			var a:Int; }
	}";

	var BLOCK_WITH_COMMENT =
	"class Test {
		public function new() {
			// comment
		}
	}";

	var EMPTY_OBJECT_DECL =
	"class Test {
		public function new() {
			var a = {};
		}
	}";

	var EMPTY_OBJECT_DECL_WHITESPACE = "
	class Test {
		public function new() {
			var a = {
			};
		}
	}";

	var OBJECT_DECL_WITH_COMMENT = "
	class Test {
		public function new() {
			var a = {
				// comment
			};
		}
	}";

	var OBJECT_DECL_WITH_COMMENT2 = "
	class Test {
		public function new() { /* comment
								 */
			var a = { // comment
			};
		}
	}";

	var MACRO_REIFICATION_ISSUE_149 = "
	class Macro
	{
		function build()
		{
			return macro
			{
				$a{exprs};
			}
		}
	}";
}