package checkstyle.checks.naming;

class MethodNameCheckTest extends CheckTestCase<MethodNameCheckTests> {
	@Test
	public function testCorrectNaming() {
		var check = new MethodNameCheck();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST4);
	}

	@Test
	public function testWrongNaming() {
		var check = new MethodNameCheck();
		var testMessage = 'Invalid method name signature: "Test" (name should be "~/${check.format}/")';
		var test1Message = 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")';
		var test2Message = 'Invalid method name signature: "Test2" (name should be "~/${check.format}/")';
		var test3Message = 'Invalid method name signature: "Test3" (name should be "~/${check.format}/")';
		assertMessages(check, TEST1, [testMessage, test2Message, test3Message]);
		assertMessages(check, TEST2, [testMessage, test1Message, test2Message, test3Message]);
		assertMsg(check, TEST3, 'Invalid method name signature: "Test" (name should be "~/${check.format}/")');
		assertMessages(check, TEST5, [testMessage, test1Message, test3Message]);
	}

	@Test
	public function testIgnoreExtern() {
		var check = new MethodNameCheck();
		check.ignoreExtern = false;

		var testMessage = 'Invalid method name signature: "Test" (name should be "~/${check.format}/")';
		var test1Message = 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")';
		var test2Message = 'Invalid method name signature: "Test2" (name should be "~/${check.format}/")';
		var test3Message = 'Invalid method name signature: "Test3" (name should be "~/${check.format}/")';
		assertNoMsg(check, TEST);
		assertMessages(check, TEST1, [testMessage, test2Message, test3Message]);
		assertMessages(check, TEST2, [testMessage, test1Message, test2Message, test3Message]);
		assertMsg(check, TEST3, testMessage);
		assertMsg(check, TEST4, testMessage);
		assertMessages(check, TEST5, [testMessage, test1Message, test3Message]);
	}

	@Test
	public function testTokenPUBLIC() {
		var check = new MethodNameCheck();
		check.tokens = [PUBLIC];
		var testMessage = 'Invalid method name signature: "Test" (name should be "~/${check.format}/")';
		var test1Message = 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")';
		var test2Message = 'Invalid method name signature: "Test2" (name should be "~/${check.format}/")';
		var test3Message = 'Invalid method name signature: "Test3" (name should be "~/${check.format}/")';

		assertNoMsg(check, TEST);
		assertMessages(check, TEST1, [testMessage, test2Message, test3Message]);
		assertMessages(check, TEST2, [testMessage, test1Message, test2Message]);
		assertMsg(check, TEST3, 'Invalid method name signature: "Test" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	@Test
	public function testTokenPRIVATE() {
		var check = new MethodNameCheck();
		check.tokens = [PRIVATE];

		var testMessage = 'Invalid method name signature: "Test" (name should be "~/${check.format}/")';
		var test1Message = 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")';
		var test2Message = 'Invalid method name signature: "Test2" (name should be "~/${check.format}/")';
		var test3Message = 'Invalid method name signature: "Test3" (name should be "~/${check.format}/")';
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, test3Message);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertMessages(check, TEST5, [testMessage, test1Message, test3Message]);
	}

	@Test
	public function testTokenSTATIC() {
		var check = new MethodNameCheck();
		check.tokens = [STATIC];
		var testMessage = 'Invalid method name signature: "Test" (name should be "~/${check.format}/")';
		var test1Message = 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")';
		var test2Message = 'Invalid method name signature: "Test2" (name should be "~/${check.format}/")';
		var test3Message = 'Invalid method name signature: "Test3" (name should be "~/${check.format}/")';

		assertNoMsg(check, TEST);
		assertMessages(check, TEST1, [testMessage, test3Message]);
		assertMessages(check, TEST2, [testMessage, test1Message]);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertMessages(check, TEST5, [testMessage, test1Message]);
	}

	@Test
	public function testTokenNOTSTATIC() {
		var check = new MethodNameCheck();
		check.tokens = [NOTSTATIC];
		var testMessage = 'Invalid method name signature: "Test" (name should be "~/${check.format}/")';
		var test1Message = 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")';
		var test2Message = 'Invalid method name signature: "Test2" (name should be "~/${check.format}/")';
		var test3Message = 'Invalid method name signature: "Test3" (name should be "~/${check.format}/")';

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, test2Message);
		assertMessages(check, TEST2, [test2Message, test3Message]);

		assertMsg(check, TEST3, testMessage);
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, test3Message);
	}

	@Test
	public function testTokenINLINE() {
		var check = new MethodNameCheck();
		check.tokens = [INLINE];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid method name signature: "Test3" (name should be "~/${check.format}/")');
		assertMsg(check, TEST2, 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")');
	}

	@Test
	public function testTokenNOTINLINE() {
		var check = new MethodNameCheck();
		check.tokens = [NOTINLINE];
		var testMessage = 'Invalid method name signature: "Test" (name should be "~/${check.format}/")';
		var test1Message = 'Invalid method name signature: "Test1" (name should be "~/${check.format}/")';
		var test2Message = 'Invalid method name signature: "Test2" (name should be "~/${check.format}/")';
		var test3Message = 'Invalid method name signature: "Test3" (name should be "~/${check.format}/")';

		assertNoMsg(check, TEST);
		assertMessages(check, TEST1, [testMessage, test2Message]);
		assertMessages(check, TEST2, [testMessage, test2Message, test3Message]);
		assertMsg(check, TEST3, testMessage);
		assertNoMsg(check, TEST4);
		assertMessages(check, TEST5, [testMessage, test3Message]);
	}

	@Test
	public function testFormat() {
		var check = new MethodNameCheck();
		check.format = "^[A-Z][a-z0-9]*$";

		assertMessages(check, TEST, [
			'Invalid method name signature: "test" (name should be "~/${check.format}/")',
			'Invalid method name signature: "testName" (name should be "~/${check.format}/")',
			'Invalid method name signature: "testValue" (name should be "~/${check.format}/")',
			'Invalid method name signature: "test" (name should be "~/${check.format}/")',
			'Invalid method name signature: "testName" (name should be "~/${check.format}/")'
		]);
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}
}

@:enum
abstract MethodNameCheckTests(String) to String {
	var TEST = "
	abstractAndClass Test {
		function test() {}
		function testName() {}
		public function testValue() {}
		public function get_Test() {}
		@SuppressWarnings('checkstyle:MethodName')
		public function TEST() {}
		@SuppressWarnings('checkstyle:MethodName')
		function TEST2() {}
	}

	typedef Test3 = {
		function test() {};
		function testName() {};
	}";
	var TEST1 = "
	abstractAndClass Test {
		static public function Test() {}
		public function Test2() {}
		static inline public function Test3() {}
	}";
	var TEST2 = "
	abstractAndClass Test {
		static public function Test() {}
		static inline public function Test1() {}
		public function Test2() {}
		function Test3() {}
	}";
	var TEST3 = "
	typedef Test = {
		public function Test() {}
	}";
	var TEST4 = "
	extern class Test {
		public function Test() {}
	}";
	var TEST5 = "
	abstractAndClass Test {
		static function Test() {}
		static inline function Test1() {}
		function Test3() {}
	}";
}