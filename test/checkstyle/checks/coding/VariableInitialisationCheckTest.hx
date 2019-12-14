package checkstyle.checks.coding;

class VariableInitialisationCheckTest extends CheckTestCase<VariableInitialisationCheckTests> {
	@Test
	public function testVar() {
		assertMsg(new VariableInitialisationCheck(), TEST1, 'Invalid variable initialisation for "_a" (move initialisation to constructor or function)');
	}

	@Test
	public function testStatic() {
		assertNoMsg(new VariableInitialisationCheck(), TEST2);
	}

	@Test
	public function testEnumAbstract() {
		assertNoMsg(new VariableInitialisationCheck(), TEST3);
	}

	@Test
	public function testFinal() {
		var check:VariableInitialisationCheck = new VariableInitialisationCheck();
		assertMsg(check, FINAL, 'Invalid variable initialisation for "VALUE" (move initialisation to constructor or function)');
		assertNoMsg(check, FINAL_CONSTRUCTOR);
		check.allowFinal = true;
		assertNoMsg(check, FINAL);
		assertNoMsg(check, FINAL_CONSTRUCTOR);
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
	var TEST2 = "
	abstractAndClass Test {
		static inline var TEST:Int = 1;
		inline var TEST2:Int = 1;

		public function new() {}
	}";
	var TEST3 = "
	@:enum
	abstract Test(Int) {
		var VALUE = 0;
	}";
	var FINAL = "
	abstractAndClass Test {
		final VALUE = 0;
	}";
	var FINAL_CONSTRUCTOR = "
	abstractAndClass Test {
		final VALUE;

		public function new() {
			VALUE = 1;
		}
	}";
}