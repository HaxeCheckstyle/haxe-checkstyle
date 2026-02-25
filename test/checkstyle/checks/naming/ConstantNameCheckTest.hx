package checkstyle.checks.naming;

class ConstantNameCheckTest extends CheckTestCase<ConstantNameCheckTests> {
	@Test
	public function testCorrectNaming() {
		var check = new ConstantNameCheck();

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST5);
	}

	@Test
	public function testWrongNaming() {
		var check = new ConstantNameCheck();
		var message = 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")';
		assertMsg(check, TEST1, message);
		assertMsg(check, TEST2, message);
		assertMsg(check, TEST3, message);
		assertMsg(check, TEST4, message);
	}

	@Test
	public function testIgnoreExtern() {
		var check = new ConstantNameCheck();
		check.ignoreExtern = false;

		var message = 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")';
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, message);
		assertMsg(check, TEST2, message);
		assertMsg(check, TEST3, message);
		assertMsg(check, TEST4, message);
		assertMessages(check, TEST5, [message, message]);
	}

	@Test
	public function testTokenINLINE() {
		var check = new ConstantNameCheck();
		check.tokens = [INLINE];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertNoMsg(check, TEST3);
		assertMsg(check, TEST4, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertNoMsg(check, TEST5);
	}

	@Test
	public function testTokenNOTINLINE() {
		var check = new ConstantNameCheck();
		check.tokens = [NOTINLINE];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertNoMsg(check, TEST2);
		assertMsg(check, TEST3, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	@Test
	public function testTokenFINAL() {
		var check = new ConstantNameCheck();
		check.tokens = [FINAL];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertMsg(check, TEST3, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertMsg(check, TEST4, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertNoMsg(check, TEST5);
	}

	@Test
	public function testTokenNOTFINAL() {
		var check = new ConstantNameCheck();
		check.tokens = [NOTFINAL];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertMsg(check, TEST2, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	@Test
	public function testFormat() {
		var check = new ConstantNameCheck();
		check.format = "^[A-Z][a-z]*$";

		assertMessages(check, TEST, [
			'Invalid const signature: "COUNT" (name should be "~/^[A-Z][a-z]*$/")',
			'Invalid const signature: "COUNT2" (name should be "~/^[A-Z][a-z]*$/")',
			'Invalid const signature: "COUNT11" (name should be "~/^[A-Z][a-z]*$/")',
			'Invalid const signature: "COUNT12" (name should be "~/^[A-Z][a-z]*$/")'
		]);
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);

		check.ignoreExtern = false;
		assertNoMsg(check, TEST3);
	}
}

enum abstract ConstantNameCheckTests(String) to String {
	var TEST = "
	abstractAndClass Test {
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		var COUNT3:Int = 1;
		var Count4:Int = 1;
		var count5:Int = 1;
		var _count5:Int = 1;

		static final COUNT11:Int = 1;
		static inline final COUNT12:Int = 1;
		final COUNT13:Int = 1;
		final Count14:Int = 1;
		final count15:Int = 1;
		final _count15:Int = 1;

		@SuppressWarnings('checkstyle:ConstantName')
		static inline var count6:Int = 1;
		@SuppressWarnings('checkstyle:ConstantName')
		static var count7:Int = 1;

		@SuppressWarnings('checkstyle:ConstantName')
		static inline final count16:Int = 1;
		@SuppressWarnings('checkstyle:ConstantName')
		static final count17:Int = 1;
	}";
	var TEST1 = "
	abstractAndClass Test {
		static var Count:Int = 1;
		public function test() {
		}
	}";
	var TEST2 = "
	abstractAndClass Test {
		static inline var Count:Int = 1;
		public function test() {
			var Count:Int;
		}
	}";
	var TEST3 = "
	abstractAndClass Test {
		static final Count:Int = 1;
		public function test() {
		}
	}";
	var TEST4 = "
	abstractAndClass Test {
		static inline final Count:Int = 1;
		public function test() {
			var Count:Int;
		}
	}";
	var TEST5 = "
	extern class Test {
		static var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";
}