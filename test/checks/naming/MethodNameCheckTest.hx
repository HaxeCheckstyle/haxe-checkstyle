package checks.naming;

import checkstyle.checks.naming.MethodNameCheck;

// TODO abstract tests
class MethodNameCheckTest extends CheckTestCase<MethodNameCheckTests> {

	public function testCorrectNaming() {
		var check = new MethodNameCheck ();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST4);
	}

	public function testWrongNaming() {
		var check = new MethodNameCheck ();
		var test3Message = 'Invalid method name signature: Test3 (name should be ~/${check.format}/)';
		assertMsg(check, TEST1, test3Message);
		assertMsg(check, TEST2, test3Message);
		assertMsg(check, TEST3, 'Invalid method name signature: Test (name should be ~/${check.format}/)');
		assertMsg(check, TEST5, test3Message);
	}

	public function testIgnoreExtern() {
		var check = new MethodNameCheck ();
		check.ignoreExtern = false;

		var testMessage = 'Invalid method name signature: Test (name should be ~/${check.format}/)';
		var test3Message = 'Invalid method name signature: Test3 (name should be ~/${check.format}/)';
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, test3Message);
		assertMsg(check, TEST2, test3Message);
		assertMsg(check, TEST3, testMessage);
		assertMsg(check, TEST4, testMessage);
		assertMsg(check, TEST5, test3Message);
	}

	public function testTokenPUBLIC() {
		var check = new MethodNameCheck ();
		check.tokens = [PUBLIC];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, TEST2, 'Invalid method name signature: Test2 (name should be ~/${check.format}/)');
		assertMsg(check, TEST3, 'Invalid method name signature: Test (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	public function testTokenPRIVATE() {
		var check = new MethodNameCheck ();
		check.tokens = [PRIVATE];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
	}

	public function testTokenSTATIC() {
		var check = new MethodNameCheck ();
		check.tokens = [STATIC];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, TEST2, 'Invalid method name signature: Test1 (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'Invalid method name signature: Test1 (name should be ~/${check.format}/)');
	}

	public function testTokenNOTSTATIC() {
		var check = new MethodNameCheck ();
		check.tokens = [NOTSTATIC];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid method name signature: Test2 (name should be ~/${check.format}/)');
		assertMsg(check, TEST2, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, TEST3, 'Invalid method name signature: Test (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
	}

	public function testTokenINLINE() {
		var check = new MethodNameCheck ();
		check.tokens = [INLINE];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, TEST2, 'Invalid method name signature: Test1 (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'Invalid method name signature: Test1 (name should be ~/${check.format}/)');
	}

	public function testTokenNOTINLINE() {
		var check = new MethodNameCheck ();
		check.tokens = [NOTINLINE];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid method name signature: Test2 (name should be ~/${check.format}/)');
		assertMsg(check, TEST2, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, TEST3, 'Invalid method name signature: Test (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
	}

	public function testFormat() {
		var check = new MethodNameCheck ();
		check.format = "^[A-Z][a-z0-9]*$";

		assertMsg(check, TEST, 'Invalid method name signature: testName (name should be ~/${check.format}/)');
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
	class Test {
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
	class Test {
		static public function Test() {}
		public function Test2() {}
		static inline public function Test3() {}
	}";

	var TEST2 = "
	class Test {
		static public function Test() {}
		static inline public function Test1() {}
		public function Test2() {}
		function Test3() {}
	}";

	var TEST3 =
	"typedef Test = {
		public function Test() {}
	}";

	var TEST4 =
	"extern class Test {
		public function Test() {}
	}";

	var TEST5 = "
	class Test {
		static function Test() {}
		static inline function Test1() {}
		function Test3() {}
	}";
}