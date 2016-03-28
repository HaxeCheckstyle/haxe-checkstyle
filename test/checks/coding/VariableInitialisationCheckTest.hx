package checks.coding;

import checkstyle.checks.coding.VariableInitialisationCheck;

class VariableInitialisationCheckTest extends CheckTestCase<VariableInitialisationCheckTests> {

	public function testVar() {
		assertMsg(new VariableInitialisationCheck(), TEST1,
		'Invalid variable "_a" initialisation (move initialisation to constructor or function)');
	}

	public function testStatic() {
		assertNoMsg(new VariableInitialisationCheck(), TEST2);
	}

	public function testEnumAbstract() {
		assertNoMsg(new VariableInitialisationCheck(), TEST3);
	}
}

@:enum
abstract VariableInitialisationCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var _a:Int = 1;

		@SuppressWarnings('checkstyle:VariableInitialisation')
		var _b:Int = 1;

		public function new() {}
	}";

	var TEST2 =
	"abstractAndClass Test {
		static inline var TEST:Int = 1;

		public function new() {}
	}";

	var TEST3 =
	"@:enum
	abstract Test(Int) {
		var VALUE = 0;
	}";
}