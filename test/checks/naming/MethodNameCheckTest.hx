package checks.naming;

import checkstyle.checks.naming.MethodNameCheck;

// TODO abstract tests
class MethodNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new MethodNameCheck ();
		assertNoMsg(check, MethodNameTests.TEST);
		assertNoMsg(check, MethodNameTests.TEST4);
	}

	public function testWrongNaming() {
		var check = new MethodNameCheck ();
		var test3Message = 'Invalid method name signature: Test3 (name should be ~/${check.format}/)';
		assertMsg(check, MethodNameTests.TEST1, test3Message);
		assertMsg(check, MethodNameTests.TEST2, test3Message);
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST5, test3Message);
	}

	public function testIgnoreExtern() {
		var check = new MethodNameCheck ();
		check.ignoreExtern = false;

		var testMessage = 'Invalid method name signature: Test (name should be ~/${check.format}/)';
		var test3Message = 'Invalid method name signature: Test3 (name should be ~/${check.format}/)';
		assertNoMsg(check, MethodNameTests.TEST);
		assertMsg(check, MethodNameTests.TEST1, test3Message);
		assertMsg(check, MethodNameTests.TEST2, test3Message);
		assertMsg(check, MethodNameTests.TEST3, testMessage);
		assertMsg(check, MethodNameTests.TEST4, testMessage);
		assertMsg(check, MethodNameTests.TEST5, test3Message);
	}

	public function testTokenPUBLIC() {
		var check = new MethodNameCheck ();
		check.tokens = [MethodNameCheck.PUBLIC];

		assertNoMsg(check, MethodNameTests.TEST);
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test2 (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/${check.format}/)');
		assertNoMsg(check, MethodNameTests.TEST4);
		assertNoMsg(check, MethodNameTests.TEST5);
	}

	public function testTokenPRIVATE() {
		var check = new MethodNameCheck ();
		check.tokens = [MethodNameCheck.PRIVATE];

		assertNoMsg(check, MethodNameTests.TEST);
		assertNoMsg(check, MethodNameTests.TEST1);
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertNoMsg(check, MethodNameTests.TEST3);
		assertNoMsg(check, MethodNameTests.TEST4);
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
	}

	public function testTokenSTATIC() {
		var check = new MethodNameCheck ();
		check.tokens = [MethodNameCheck.STATIC];

		assertNoMsg(check, MethodNameTests.TEST);
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test1 (name should be ~/${check.format}/)');
		assertNoMsg(check, MethodNameTests.TEST3);
		assertNoMsg(check, MethodNameTests.TEST4);
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test1 (name should be ~/${check.format}/)');
	}

	public function testTokenNOTSTATIC() {
		var check = new MethodNameCheck ();
		check.tokens = [MethodNameCheck.NOTSTATIC];

		assertNoMsg(check, MethodNameTests.TEST);
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test2 (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/${check.format}/)');
		assertNoMsg(check, MethodNameTests.TEST4);
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
	}

	public function testTokenINLINE() {
		var check = new MethodNameCheck ();
		check.tokens = [MethodNameCheck.INLINE];

		assertNoMsg(check, MethodNameTests.TEST);
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test1 (name should be ~/${check.format}/)');
		assertNoMsg(check, MethodNameTests.TEST3);
		assertNoMsg(check, MethodNameTests.TEST4);
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test1 (name should be ~/${check.format}/)');
	}

	public function testTokenNOTINLINE() {
		var check = new MethodNameCheck ();
		check.tokens = [MethodNameCheck.NOTINLINE];

		assertNoMsg(check, MethodNameTests.TEST);
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test2 (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/${check.format}/)');
		assertNoMsg(check, MethodNameTests.TEST4);
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test3 (name should be ~/${check.format}/)');
	}

	public function testFormat() {
		var check = new MethodNameCheck ();
		check.format = "^[A-Z][a-z0-9]*$";

		assertMsg(check, MethodNameTests.TEST, 'Invalid method name signature: testName (name should be ~/${check.format}/)');
		assertNoMsg(check, MethodNameTests.TEST1);
		assertNoMsg(check, MethodNameTests.TEST2);
		assertNoMsg(check, MethodNameTests.TEST3);
		assertNoMsg(check, MethodNameTests.TEST4);
		assertNoMsg(check, MethodNameTests.TEST5);
	}
}

class MethodNameTests {
	public static inline var TEST:String = "
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

	public static inline var TEST1:String = "
	class Test {
		static public function Test() {}
		public function Test2() {}
		static inline public function Test3() {}
	}";

	public static inline var TEST2:String = "
	class Test {
		static public function Test() {}
		static inline public function Test1() {}
		public function Test2() {}
		function Test3() {}
	}";

	public static inline var TEST3:String =
	"typedef Test = {
		public function Test() {}
	}";

	public static inline var TEST4:String =
	"extern class Test {
		public function Test() {}
	}";

	public static inline var TEST5:String = "
	class Test {
		static function Test() {}
		static inline function Test1() {}
		function Test3() {}
	}";
}