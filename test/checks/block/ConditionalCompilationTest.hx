package checks.block;

import checkstyle.checks.block.ConditionalCompilationCheck;

class ConditionalCompilationTest extends CheckTestCase<ConditionalCompilationTests> {

	static inline var MSG_START_OF_LINE:String = "#if should start at beginning of line";
	static inline var MSG_NOT_ALIGNED:String = "Indentation of #if should match surrounding lines";
	static inline var MSG_NO_SINGLELINE:String = "Single line #if…(#else/#elseif)…#end not allowed";
	static inline var MSG_WRONG_INDENT:String = "Indentation of #else must match corresponding #if";
	static inline var MSG_WHITESPACE_BEFORE:String = "only whitespace allowed before #if";
	static inline var MSG_WHITESPACE_AFTER:String = "only whitespace allowed after #if";

	@Test
	public function testAlignedWithSingleline() {
		var check:ConditionalCompilationCheck = new ConditionalCompilationCheck();

		assertNoMsg(check, ISSUE_76);
		assertNoMsg(check, ISSUE_79);
		assertNoMsg(check, ISSUE_252);

		assertMsg(check, ISSUE_76_START_OF_LINE, MSG_NOT_ALIGNED);
		assertMsg(check, ISSUE_79_START_OF_LINE, MSG_NOT_ALIGNED);
		assertMsg(check, ISSUE_79_WRONG_INDENT, MSG_WRONG_INDENT);
	}

	@Test
	public function testAlignedWithNoSingleline() {
		var check:ConditionalCompilationCheck = new ConditionalCompilationCheck();
		check.allowSingleline = false;

		assertNoMsg(check, ISSUE_76);
		assertNoMsg(check, ISSUE_79);
		assertMsg(check, ISSUE_252, MSG_NO_SINGLELINE);

		assertMsg(check, ISSUE_76_START_OF_LINE, MSG_NOT_ALIGNED);
		assertMsg(check, ISSUE_79_START_OF_LINE, MSG_NOT_ALIGNED);
		assertMsg(check, ISSUE_79_WRONG_INDENT, MSG_WRONG_INDENT);
	}

	@Test
	public function testStartOfLine() {
		var check:ConditionalCompilationCheck = new ConditionalCompilationCheck();
		check.allowSingleline = false;
		check.policy = START_OF_LINE;

		assertNoMsg(check, ISSUE_76_START_OF_LINE);
		assertNoMsg(check, ISSUE_79_START_OF_LINE);

		assertMsg(check, ISSUE_76, MSG_START_OF_LINE);
		assertMsg(check, ISSUE_79, MSG_START_OF_LINE);
		assertMsg(check, ISSUE_252, MSG_NO_SINGLELINE);
	}

	@Test
	public function testWhitespace() {
		var check:ConditionalCompilationCheck = new ConditionalCompilationCheck();

		assertMsg(check, ISSUE_79_WHITESPACE_BEFORE, MSG_WHITESPACE_BEFORE);
		assertMsg(check, ISSUE_79_WHITESPACE_AFTER, MSG_WHITESPACE_AFTER);

		check.policy = START_OF_LINE;

		assertMsg(check, ISSUE_79_WHITESPACE_BEFORE, MSG_WHITESPACE_BEFORE);
		assertMsg(check, ISSUE_79_WHITESPACE_AFTER, MSG_WHITESPACE_AFTER);
	}
}

@:enum
abstract ConditionalCompilationTests(String) to String {

	var ISSUE_76 = "
	class Base {}

	#if true

	class Test extends Base
	#else
	class Test
	#end
	{
	}";

	var ISSUE_79 = "
	class Test {
		function foo() {

			#if true
			if (true) {
			#else
			if (true) {
			#end

			}
		}
	}";

	var ISSUE_79_WRONG_INDENT = "
	class Test {
		function foo() {
			#if true
			if (true) {
		#else
			if (true) {
			#end

			}
		}
	}";

	var ISSUE_79_WHITESPACE_BEFORE = "
	class Test {
		function foo() { #if true
			if (true) { #else
			if (true) {
			#end

			}
		}
	}";

	var ISSUE_79_WHITESPACE_AFTER = "
	class Test {
		function foo() {
			#if true if (true) {
			#else if (true) {
			#end

			}
		}
	}";

	var ISSUE_76_START_OF_LINE = "
	class Base {}

#if true

	class Test extends Base
#else
	class Test
#end
	{
	}";

	var ISSUE_79_START_OF_LINE = "
	class Test {
		function foo() {
#if true
			if (true) {
#else
			if (true) {
#end

			}
		}
	}";

	var ISSUE_252 = "
	class Foo {
		var library = new #if haxe3 Map<String, #else Hash <#end String>();
	}";
}