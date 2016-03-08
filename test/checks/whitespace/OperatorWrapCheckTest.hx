package checks.whitespace;

import checkstyle.checks.whitespace.OperatorWrapCheck;

class OperatorWrapCheckTest extends CheckTestCase<OperatorWrapCheckTests> {

	static inline var MSG_PLUS_EOL:String = 'Token "+" must be at the end of the line';
	static inline var MSG_GT_NL:String = 'Token ">" must be on a new line';

	public function testCorrectWrap() {
		var check = new OperatorWrapCheck();
		assertNoMsg(check, CORRECT_EOL_WRAP);
		assertNoMsg(check, TYPE_PARAM);
	}

	public function testIncorrectWrap() {
		var check = new OperatorWrapCheck();
		assertMsg(check, CORRECT_NL_WRAP_PLUS, MSG_PLUS_EOL);
	}

	public function testOptionNL() {
		var check = new OperatorWrapCheck();
		check.option = NL;
		assertNoMsg(check, CORRECT_NL_WRAP_PLUS);
		assertNoMsg(check, CORRECT_NL_WRAP_GT);
		assertNoMsg(check, TYPE_PARAM);

		assertMsg(check, CORRECT_EOL_WRAP, MSG_GT_NL);
	}
}

@:enum
abstract OperatorWrapCheckTests(String) to String {
	var CORRECT_EOL_WRAP = "
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

	var CORRECT_NL_WRAP_PLUS = "
	class Test {
		function test() {
			var test = test1
				+ test2;
		}
	}";

	var CORRECT_NL_WRAP_GT = "
	class Test {
		function test() {
			return a
				< b;
		}
	}";

	var TYPE_PARAM = "
	class Test {
		function foo():Array<Int>
		{
			trace('test');
		}
	}";
}