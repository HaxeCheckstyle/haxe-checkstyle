package checks.coding;

import checkstyle.checks.coding.VariableInitialisationCheck;

class VariableInitialisationCheckTest extends CheckTestCase {

	public function testVar() {
		assertMsg(new VariableInitialisationCheck(), VariableInitialisationTests.TEST1,
			'Invalid variable initialisation: _a (move initialisation to constructor or function)');
	}

	public function testStatic() {
		assertNoMsg(new VariableInitialisationCheck(), VariableInitialisationTests.TEST2);
	}

	public function testEnumAbstract() {
		assertNoMsg(new VariableInitialisationCheck(), VariableInitialisationTests.TEST3);
	}
}

class VariableInitialisationTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		var _a:Int = 1;

		@SuppressWarnings('checkstyle:VariableInitialisation')
		var _b:Int = 1;

		public function new() {}
	}";

	public static inline var TEST2:String =
	"abstractAndClass Test {
		static inline var TEST:Int = 1;

		public function new() {}
	}";

	public static inline var TEST3:String =
	"@:enum
	abstract Test(Int) {
		var VALUE = 0;
	}";
}