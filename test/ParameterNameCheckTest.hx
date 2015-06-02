package ;

import checkstyle.checks.ParameterNameCheck;

// TODO abstract tests
class ParameterNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new ParameterNameCheck ();
		assertMsg(check, ParameterNameTests.TEST, '');
		assertMsg(check, ParameterNameTests.TEST2, '');
		assertMsg(check, ParameterNameTests.TEST4, '');
	}

	public function testWrongNaming() {
		var check = new ParameterNameCheck ();
		assertMsg(check, ParameterNameTests.TEST1, 'Invalid parameter name signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, ParameterNameTests.TEST3, 'Invalid parameter name signature: ParamName (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, ParameterNameTests.TEST5, 'Invalid parameter name signature: ParamName (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
	}

	public function testIgnoreExtern() {
		var check = new ParameterNameCheck ();
		check.ignoreExtern = false;

		assertMsg(check, ParameterNameTests.TEST, '');
		assertMsg(check, ParameterNameTests.TEST2, '');
		assertMsg(check, ParameterNameTests.TEST1, 'Invalid parameter name signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, ParameterNameTests.TEST3, 'Invalid parameter name signature: ParamName (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, ParameterNameTests.TEST4, 'Invalid parameter name signature: Param1 (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, ParameterNameTests.TEST5, 'Invalid parameter name signature: ParamName (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
	}

	public function testFormat() {
		var check = new ParameterNameCheck ();
		check.format = "^[A-Z][a-zA-Z]*$";

		assertMsg(check, ParameterNameTests.TEST, 'Invalid parameter name signature: paramName (name should be ~/^[A-Z][a-zA-Z]*$/)');
		assertMsg(check, ParameterNameTests.TEST2, '');
		assertMsg(check, ParameterNameTests.TEST1, '');
		assertMsg(check, ParameterNameTests.TEST3, 'Invalid parameter name signature: param1 (name should be ~/^[A-Z][a-zA-Z]*$/)');
		assertMsg(check, ParameterNameTests.TEST4, '');
		assertMsg(check, ParameterNameTests.TEST5, '');
	}
}

class ParameterNameTests {
	public static inline var TEST:String = "
	class Test {
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

	public static inline var TEST1:String = "
	class Test {
		public function test(Count:Int) {
		}
	}";

	public static inline var TEST2:String = "
	class Test {
		public function test() {
		}
	}";

	public static inline var TEST3:String =
	"typedef Test = {
		function test(param1:Int, ParamName:String) {
		}
	}";

	public static inline var TEST4:String =
	"extern class Test {
		public function test(Param1:Int) {
		}
	}";

	public static inline var TEST5:String =
	"enum Test {
		VALUE(ParamName:String);
	}";
}