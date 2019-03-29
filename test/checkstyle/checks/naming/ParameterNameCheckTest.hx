package checkstyle.checks.naming;

class ParameterNameCheckTest extends CheckTestCase<ParameterNameCheckTests> {
	@Test
	public function testCorrectNaming() {
		var check = new ParameterNameCheck();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST4);
	}

	@Test
	public function testWrongNaming() {
		var check = new ParameterNameCheck();
		assertMsg(check, TEST1, 'Invalid parameter name signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST3, 'Invalid parameter name signature: "ParamName" (name should be "~/${check.format}/")');
		assertMsg(check, TEST5, 'Invalid parameter name signature: "ParamName" (name should be "~/${check.format}/")');
	}

	@Test
	public function testIgnoreExtern() {
		var check = new ParameterNameCheck();
		check.ignoreExtern = false;

		var paramNameMessage = 'Invalid parameter name signature: "ParamName" (name should be "~/${check.format}/")';
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST2);
		assertMsg(check, TEST1, 'Invalid parameter name signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST3, paramNameMessage);
		assertMsg(check, TEST4, 'Invalid parameter name signature: "Param1" (name should be "~/${check.format}/")');
		assertMsg(check, TEST5, paramNameMessage);
	}

	@Test
	public function testFormat() {
		var check = new ParameterNameCheck();
		check.format = "^[A-Z][a-zA-Z]*$";

		assertMsg(check, TEST, 'Invalid parameter name signature: "paramName" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST3, 'Invalid parameter name signature: "param1" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}
}

@:enum
abstract ParameterNameCheckTests(String) to String {
	var TEST = "
	abstractAndClass Test {
		function test(param1:Int, paramName:String) {
		}
		public function test2() {
		}

		@SuppressWarnings('checkstyle:ParameterName')
		function test(param1:Int, ParamName:String) {
		}
	}

	enum Test2 {
		count(param:Int);
	}

	typedef Test3 = {
		function test(param1:Int, paramName:String) {
		}
	}";
	var TEST1 = "
	abstractAndClass Test {
		public function test(Count:Int) {
		}
	}";
	var TEST2 = "
	abstractAndClass Test {
		public function test() {
		}
	}";
	var TEST3 = "
	typedef Test = {
		function test(param1:Int, ParamName:String) {
		}
	}";
	var TEST4 = "
	extern class Test {
		public function test(Param1:Int) {
		}
	}";
	var TEST5 = "
	enum Test {
		VALUE(ParamName:String);
	}";
}