package checkstyle.checks.naming;

class LocalVariableNameCheckTest extends CheckTestCase<LocalVariableNameCheckTests> {
	@Test
	public function testCorrectNaming() {
		var check = new LocalVariableNameCheck();

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST_FINAL_1);
	}

	@Test
	public function testWrongNaming() {
		var check = new LocalVariableNameCheck();

		assertMsg(check, TEST1, 'Invalid local var signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST3, 'Invalid local var signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST_FINAL_2, 'Invalid local var signature: "Count1" (name should be "~/${check.format}/")');
	}

	@Test
	public function testIgnoreExtern() {
		var check = new LocalVariableNameCheck();
		check.ignoreExtern = false;

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid local var signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST3, 'Invalid local var signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST4, 'Invalid local var signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST_FINAL_2, 'Invalid local var signature: "Count1" (name should be "~/${check.format}/")');
	}

	@Test
	public function testTokenFINAL() {
		var check = new LocalVariableNameCheck();
		check.ignoreExtern = false;
		check.tokens = [FINAL];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST_FINAL_1);

		assertMsg(check, TEST_FINAL_2, 'Invalid local var signature: "Count1" (name should be "~/${check.format}/")');
	}

	@Test
	public function testTokenNONFINAL() {
		var check = new LocalVariableNameCheck();
		check.ignoreExtern = false;
		check.tokens = [NOTFINAL];

		assertNoMsg(check, TEST);

		assertMsg(check, TEST1, 'Invalid local var signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST3, 'Invalid local var signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST4, 'Invalid local var signature: "Count" (name should be "~/${check.format}/")');

		assertNoMsg(check, TEST_FINAL_1);
		assertNoMsg(check, TEST_FINAL_2);
	}

	@Test
	public function testFormat() {
		var check = new LocalVariableNameCheck();
		check.format = "^[A-Za-z_]*$";

		assertMessages(check, TEST, [
			'Invalid local var signature: "count1" (name should be "~/${check.format}/")',
			'Invalid local var signature: "count2" (name should be "~/${check.format}/")'
		]);

		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);

		assertMsg(check, TEST_FINAL_1, 'Invalid local var signature: "count1" (name should be "~/${check.format}/")');
		assertMsg(check, TEST_FINAL_2, 'Invalid local var signature: "Count1" (name should be "~/${check.format}/")');
	}
}

enum abstract LocalVariableNameCheckTests(String) to String {
	var TEST = "
	class Test {
		public function test() {
			var a:Int;
			var b:Int;
		}
		@SuppressWarnings('checkstyle:LocalVariableName')
		public function test() {
			var I:Int;
		}
	}

	enum Test2 {
		count;
		a;
	}

	typedef Test3 = {
		public function test() {
			var count1:Int;
			var count2:String;
		};
		@SuppressWarnings('checkstyle:LocalVariableName')
		var COUNT6:Int = 1;
	}

	typedef Test4 = {
		@SuppressWarnings('checkstyle:LocalVariableName')
		public function test() {
			var Count1:Int;
		};
	}";
	var TEST1 = "
	class Test {
		public function test() {
			var Count:Int = 1;
		}
	}";
	var TEST3 = "
	typedef Test = {
		public function test() {
			var Count:Int;
		}
	}";
	var TEST4 = "
	extern class Test {
		public function test() {
			var Count:Int = 1;
		}
	}";

	var TEST_FINAL_1 = "
	class Test {
		public function test() {
			final count1:Int = 1;
		}
	}";
	var TEST_FINAL_2 = "
	class Test {
		public function test() {
			final Count1:Int = 1;
		}
	}";
}