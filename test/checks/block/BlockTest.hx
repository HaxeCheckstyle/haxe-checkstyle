package checks.block;

import checkstyle.checks.block.EmptyBlockCheck;
import checkstyle.checks.block.LeftCurlyCheck;
import checkstyle.checks.block.RightCurlyCheck;

// tests for blocks using multiple check classes
class BlockTest extends CheckTestCase<BlockTests> {

	@Test
	public function testBlockFormatIssue42() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertNoMsg(check, ISSUE_42);
		assertNoMsg(check, ISSUE_42_MACRO);

		var checkLeft:LeftCurlyCheck = new LeftCurlyCheck();
		checkLeft.option = NL;
		assertNoMsg(checkLeft, ISSUE_42);
		assertNoMsg(checkLeft, ISSUE_42_MACRO);

		var checkRight:RightCurlyCheck = new RightCurlyCheck();
		assertNoMsg(checkRight, ISSUE_42);
		assertNoMsg(checkRight, ISSUE_42_MACRO);
	}

	@Test
	public function testBlockFormatIssue42Eol() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertNoMsg(check, ISSUE_42_MACRO_EOL);

		var checkLeft:LeftCurlyCheck = new LeftCurlyCheck();
		assertNoMsg(checkLeft, ISSUE_42_MACRO_EOL);

		var checkRight:RightCurlyCheck = new RightCurlyCheck();
		assertNoMsg(checkRight, ISSUE_42_MACRO_EOL);
	}
}

@:enum
abstract BlockTests(String) to String {

	var ISSUE_42 = "
	abstractAndClass Macro
	{
		function build()
		{
			return
			{
				while (true)
					trace('');
			}
		}
	}";

	var ISSUE_42_MACRO = "
	abstractAndClass Macro
	{
		function build()
		{
			return macro
			{
				while (true)
					trace('');
			}
		}
	}";

	var ISSUE_42_MACRO_EOL = "
	abstractAndClass Macro {
		function build() {
			return macro {
				while (true)
					trace('');
			}
		}
	}";
}