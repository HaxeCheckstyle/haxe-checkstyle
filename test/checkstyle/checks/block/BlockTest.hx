package checkstyle.checks.block;

// tests for blocks using multiple check classes
class BlockTest extends CheckTestCase<BlockTests> {
	@Test
	public function testBlockFormatIssue42() {
		var check:EmptyBlockCheck = new EmptyBlockCheck();
		assertNoMsg(check, ISSUE_42);
		assertNoMsg(check, ISSUE_42_MACRO);
		assertNoMsg(check, CONDITIONAL_TEST);

		var checkLeft:LeftCurlyCheck = new LeftCurlyCheck();
		checkLeft.option = NL;
		assertNoMsg(checkLeft, ISSUE_42);
		assertNoMsg(checkLeft, ISSUE_42_MACRO);

		var checkRight:RightCurlyCheck = new RightCurlyCheck();
		assertNoMsg(checkRight, ISSUE_42);
		assertNoMsg(checkRight, ISSUE_42_MACRO);
		assertNoMsg(checkRight, CONDITIONAL_TEST);
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
	var CONDITIONAL_TEST = "
	abstractAndClass Test {
		#if false
		function build() {
		#else
		function build2() {
		#end
		}

		function test() {
			#if debug
			try {
			#end

			#if debug
			catch(e) {
				// nothing
			}
			#end
		}
	}";
}