package ;

import checkstyle.checks.ParameterNameCheck;

// TODO abstract tests
class ParameterNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var msg = checkMessage (ParameterNameTests.TEST, new ParameterNameCheck ());
		assertEquals ('', msg);

		msg = checkMessage (ParameterNameTests.TEST2, new ParameterNameCheck ());
		assertEquals ('', msg);

		msg = checkMessage (ParameterNameTests.TEST4, new ParameterNameCheck ());
		assertEquals ('', msg);
	}

	public function testWrongNaming() {
		var msg = checkMessage (ParameterNameTests.TEST1, new ParameterNameCheck ());
		assertEquals ('Invalid parameter name signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (ParameterNameTests.TEST3, new ParameterNameCheck ());
		assertEquals ('Invalid parameter name signature: ParamName (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (ParameterNameTests.TEST5, new ParameterNameCheck ());
		assertEquals ('Invalid parameter name signature: ParamName (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);
	}

	public function testIgnoreExtern() {
		var check = new ParameterNameCheck ();
		check.ignoreExtern = false;

		var msg = checkMessage (ParameterNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (ParameterNameTests.TEST4, new ParameterNameCheck ());
		assertEquals ('Invalid parameter name signature: Param1 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (ParameterNameTests.TEST3, new ParameterNameCheck ());
		assertEquals ('Invalid parameter name signature: ParamName (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (ParameterNameTests.TEST5, new ParameterNameCheck ());
		assertEquals ('Invalid parameter name signature: ParamName (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);
	}

	public function testFormat() {
		var check = new ParameterNameCheck ();
		check.format = "^[A-Z][a-zA-Z]*$";

		var msg = checkMessage (ParameterNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (ParameterNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (ParameterNameTests.TEST2, check);
		assertEquals ('', msg);

		msg = checkMessage (ParameterNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (ParameterNameTests.TEST, check);
		assertEquals ('Invalid parameter name signature: paramName (name should be ~/^[A-Z][a-zA-Z]*$/)', msg);

		msg = checkMessage (ParameterNameTests.TEST3, check);
		assertEquals ('Invalid parameter name signature: param1 (name should be ~/^[A-Z][a-zA-Z]*$/)', msg);
	}
}

class ParameterNameTests {
	public static inline var TEST:String = "
	class Test {
		function test(param1:Int, paramName:String) {
		}
		public function test2() {
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
