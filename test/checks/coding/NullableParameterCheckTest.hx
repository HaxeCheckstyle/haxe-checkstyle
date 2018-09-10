package checks.coding;

import checks.CheckTestCase;
import checkstyle.checks.coding.NullableParameterCheck;

class NullableParameterCheckTest extends CheckTestCase<NullableParameterCheckTests> {
	@Test
	function testQuestionMark() {
		var check = new NullableParameterCheck();
		check.option = QUESTION_MARK;

		assertNoMsg(check, NO_DEFAULT);
		assertNoMsg(check, DEFAULT);
		assertMsg(check, NULL_DEFAULT, 'Function parameter "arg = null" should be "?arg"');
		assertNoMsg(check, OPTIONAL);
		assertMsg(check, OPTIONAL_WITH_NULL_DEFAULT, 'Function parameter "?arg = null" should be "?arg"');
		assertNoMsg(check, OPTIONAL_WITH_NON_NULL_DEFAULT);
	}

	@Test
	function testNullDefault() {
		var check = new NullableParameterCheck();
		check.option = NULL_DEFAULT;

		assertNoMsg(check, NO_DEFAULT);
		assertNoMsg(check, DEFAULT);
		assertNoMsg(check, NULL_DEFAULT);
		assertMsg(check, OPTIONAL, 'Function parameter "?arg" should be "arg = null"');
		assertMsg(check, OPTIONAL_WITH_NULL_DEFAULT, 'Function parameter "?arg = null" should be "arg = null"');
		assertNoMsg(check, OPTIONAL_WITH_NON_NULL_DEFAULT);
	}
}

@:enum
abstract NullableParameterCheckTests(String) to String {
	var NO_DEFAULT = "
	class Test {
		function foo(arg:Int) {}
	}";
	var DEFAULT = "
	class Test {
		function foo(arg:Int = 0) {}
	}";
	var NULL_DEFAULT = "
	class Test {
		function foo(arg:Int = null) {}
	}";
	var OPTIONAL = "
	class Test {
		function foo(?arg:Int) {}
	}";
	var OPTIONAL_WITH_NULL_DEFAULT = "
	class Test {
		function foo(?arg:Int = null) {}
	}";
	var OPTIONAL_WITH_NON_NULL_DEFAULT = "
	class Test {
		function foo(?arg:Int = 0) {}
	}";
}