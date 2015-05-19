package ;

import checkstyle.checks.ParameterNumberCheck;

class ParameterNumberCheckTest extends CheckTestCase {

	public function testNoParams() {
		var msg = checkMessage(ParameterNumberTests.TEST1, new ParameterNumberCheck());
		assertEquals('', msg);
	}

	public function test10Parameters() {
		var msg = checkMessage(ParameterNumberTests.TEST2, new ParameterNumberCheck());
		assertEquals('', msg);
	}

	public function test11Parameters() {
		var msg = checkMessage(ParameterNumberTests.TEST3, new ParameterNumberCheck());
		assertEquals('Too many parameters for function: test2 (> 10)', msg);
	}

	public function testMaxParameter() {
		var check = new ParameterNumberCheck();
		check.max = 11;
		var msg = checkMessage(ParameterNumberTests.TEST3, check);
		assertEquals('', msg);

		check.max = 3;

		var msg = checkMessage(ParameterNumberTests.TEST4, check);
		assertEquals('', msg);

		msg = checkMessage(ParameterNumberTests.TEST3, check);
		assertEquals('Too many parameters for function: test2 (> 3)', msg);
	}

	public function testInterface() {
		var msg = checkMessage(ParameterNumberTests.TEST5, new ParameterNumberCheck());
		assertEquals('Too many parameters for function: test4 (> 10)', msg);
	}

	public function testIgnoreOverridenMethods() {
		var check = new ParameterNumberCheck();
		check.ignoreOverriddenMethods = true;

		var msg = checkMessage(ParameterNumberTests.TEST3, check);
		assertEquals('', msg);
	}
}

class ParameterNumberTests {
	public static inline var TEST1:String = "
	class Test {
		var testVar1:Int;
		public function test():Void {}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function test1(param1:Int,
								param2:Int,
								param3:Int,
								param4:Int,
								param5:Int,
								param6:Int,
								param7:Int,
								param8:Int,
								param9:Int,
								param10:Int) {
			return;
		}
	}";

	public static inline var TEST3:String =
	"class Test {
		override public function test2(param1:Int,
								param2:Int,
								param3:Int,
								param4:Int,
								param5:Int,
								param6:Int,
								param7:Int,
								param8:Int,
								param9:Int,
								param10:Int,
								param11:Int) {
			return;
		}
	}";
	
	public static inline var TEST4:String =
	"class Test {
		public function test3(param1:Int,
								param2:Int,
								param3:Int) {
			return;
		}
	}";

	public static inline var TEST5:String =
	"interface ITest {
		public function test4(param1:Int,
								param2:Int,
								param3:Int,
								param4:Int,
								param5:Int,
								param6:Int,
								param7:Int,
								param8:Int,
								param9:Int,
								param10:Int,
								param11:Int);
	}";
}
