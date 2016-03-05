package checks.whitespace;

import checkstyle.checks.whitespace.OperatorWrapCheck;

class OperatorWrapCheckTest extends CheckTestCase {

	static inline var MSG_PLUS_EOL:String = 'Token "+" must be at the end of the line';
	static inline var MSG_GT_NL:String = 'Token ">" must be on a new line';

	public function testCorrectWrap() {
		var check = new OperatorWrapCheck();
		assertNoMsg(check, OperatorWrapTests.CORRECT_EOL_WRAP);
		assertNoMsg(check, OperatorWrapTests.TYPE_PARAM);
	}

	public function testIncorrectWrap() {
		var check = new OperatorWrapCheck();
		assertMsg(check, OperatorWrapTests.CORRECT_NL_WRAP_PLUS, MSG_PLUS_EOL);
	}

	public function testOptionNL() {
		var check = new OperatorWrapCheck();
		check.option = "nl";
		assertNoMsg(check, OperatorWrapTests.CORRECT_NL_WRAP_PLUS);
		assertNoMsg(check, OperatorWrapTests.CORRECT_NL_WRAP_GT);
		assertNoMsg(check, OperatorWrapTests.TYPE_PARAM);

		assertMsg(check, OperatorWrapTests.CORRECT_EOL_WRAP, MSG_GT_NL);
	}
}

class OperatorWrapTests {
	public static inline var CORRECT_EOL_WRAP:String = "
	class Test {
		function test(param1:String, param2:String) {
			var test = test1 +
				test2;
			test = test1 + test2;
			test = a < b;
			test = a <
				b;
			test = a >
				b;
			test = a > b;
		}
		function foo():Array<Int> {
			trace('test');
		}
	}";

	public static inline var CORRECT_NL_WRAP_PLUS:String = "
	class Test {
		function test() {
			var test = test1
				+ test2;
		}
	}";

	public static inline var CORRECT_NL_WRAP_GT:String = "
	class Test {
		function test() {
			return a
				< b;
		}
	}";

	public static inline var TYPE_PARAM:String = "
	class Test {
		function foo():Array<Int>
		{
			trace('test');
		}
	}";
}