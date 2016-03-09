package checks.size;

import checkstyle.checks.size.ParameterNumberCheck;

class ParameterNumberCheckTest extends CheckTestCase<ParameterNumberCheckTests> {

	public function testNoParams() {
		var check = new ParameterNumberCheck();
		assertNoMsg(check, TEST1);
	}

	public function test10Parameters() {
		var check = new ParameterNumberCheck();
		assertNoMsg(check, TEST2);
	}

	public function test11Parameters() {
		var check = new ParameterNumberCheck();
		assertMsg(check, TEST3, 'Too many parameters for function: test2 (> 7)');
	}

	public function testMaxParameter() {
		var check = new ParameterNumberCheck();
		check.max = 11;

		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);

		check.max = 3;
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST3, 'Too many parameters for function: test2 (> 3)');
	}

	public function testInterface() {
		var check = new ParameterNumberCheck();
		assertMsg(check, TEST5, 'Too many parameters for function: test4 (> 7)');
	}

	public function testIgnoreOverridenMethods() {
		var check = new ParameterNumberCheck();
		check.ignoreOverriddenMethods = true;

		assertNoMsg(check, TEST3);
	}
}

@:enum
abstract ParameterNumberCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var testVar1:Int;
		public function test():Void {}

		@SuppressWarnings('checkstyle:ParameterNumber')
		override public function test2(param1:Int,
								param2:Int,
								param3:Int,
								param4:Int,
								param5:Int,
								param6:Int,
								param7:Int,
								param8:Int) {
			return;
		}
	}";

	var TEST2 =
	"abstractAndClass Test {
		public function test1(param1:Int,
								param2:Int,
								param3:Int,
								param4:Int,
								param5:Int,
								param6:Int,
								param7:Int) {
			return 3;
		}
	}";

	var TEST3 =
	"abstractAndClass Test {
		override public function test2(param1:Int,
								param2:Int,
								param3:Int,
								param4:Int,
								param5:Int,
								param6:Int,
								param7:Int,
								param8:Int) {
			return;
		}
	}";

	var TEST4 =
	"abstractAndClass Test {
		public function test3(param1:Int,
								param2:Int,
								param3:Int) {
			return;
		}
	}";

	var TEST5 =
	"interface ITest {
		public function test4(param1:Int,
								param2:Int,
								param3:Int,
								param4:Int,
								param5:Int,
								param6:Int,
								param7:Int,
								param8:Int);
	}";
}