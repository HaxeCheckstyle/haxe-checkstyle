package ;

import checkstyle.checks.VariableInitialisationCheck;

class VariableInitialisationCheckTest extends CheckTestCase {

	public function testVar() {
		var msg = checkMessage(VariableInitialisationTests.TEST1, new VariableInitialisationCheck());
		assertEquals(msg, 'Invalid variable initialisation: _a (move initialisation to constructor or function)');
	}

	public function testStatic() {
		var msg = checkMessage(VariableInitialisationTests.TEST2, new VariableInitialisationCheck());
		assertEquals(msg, '');
	}
}

class VariableInitialisationTests {
	public static inline var TEST1:String = "
	class Test {
		var _a:Int = 1;

		@SuppressWarnings('checkstyle:VariableInitialisation')
		var _b:Int = 1;

		public function new() {}
	}";

	public static inline var TEST2:String =
	"class Test {
		static inline var TEST:Int = 1;

		public function new() {}
	}";
}