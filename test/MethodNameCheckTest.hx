package ;

import checkstyle.checks.MethodNameCheck;

// TODO abstract tests
class MethodNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new MethodNameCheck ();
		assertMsg(check, MethodNameTests.TEST, '');
		assertMsg(check, MethodNameTests.TEST4, '');
	}

	public function testWrongNaming() {
		var check = new MethodNameCheck ();
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
	}

	public function testIgnoreExtern() {
		var check = new MethodNameCheck ();
		check.ignoreExtern = false;

		assertMsg(check, MethodNameTests.TEST, '');
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST4, 'Invalid method name signature: Test (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
	}

	public function testTokenPUBLIC() {
		var check = new MethodNameCheck ();
		check.tokens = [ "PUBLIC" ];

		assertMsg(check, MethodNameTests.TEST, '');
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test2 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST4, '');
		assertMsg(check, MethodNameTests.TEST5, '');
	}

	public function testTokenPRIVATE() {
		var check = new MethodNameCheck ();
		check.tokens = [ "PRIVATE" ];

		assertMsg(check, MethodNameTests.TEST, '');
		assertMsg(check, MethodNameTests.TEST1, '');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST3, '');
		assertMsg(check, MethodNameTests.TEST4, '');
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
	}

	public function testTokenSTATIC() {
		var check = new MethodNameCheck ();
		check.tokens = [ "STATIC" ];

		assertMsg(check, MethodNameTests.TEST, '');
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test1 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST3, '');
		assertMsg(check, MethodNameTests.TEST4, '');
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test1 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
	}

	public function testTokenNOTSTATIC() {
		var check = new MethodNameCheck ();
		check.tokens = [ "NOTSTATIC" ];

		assertMsg(check, MethodNameTests.TEST, '');
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test2 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST4, '');
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
	}

	public function testTokenINLINE() {
		var check = new MethodNameCheck ();
		check.tokens = [ "INLINE" ];

		assertMsg(check, MethodNameTests.TEST, '');
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test1 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST3, '');
		assertMsg(check, MethodNameTests.TEST4, '');
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test1 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
	}

	public function testTokenNOTINLINE() {
		var check = new MethodNameCheck ();
		check.tokens = [ "NOTINLINE" ];

		assertMsg(check, MethodNameTests.TEST, '');
		assertMsg(check, MethodNameTests.TEST1, 'Invalid method name signature: Test2 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST2, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST3, 'Invalid method name signature: Test (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
		assertMsg(check, MethodNameTests.TEST4, '');
		assertMsg(check, MethodNameTests.TEST5, 'Invalid method name signature: Test3 (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)');
	}

	public function testFormat() {
		var check = new MethodNameCheck ();
		check.format = "^[A-Z][a-z0-9]*$";

		assertMsg(check, MethodNameTests.TEST, 'Invalid method name signature: testName (name should be ~/^[A-Z][a-z0-9]*$/)');
		assertMsg(check, MethodNameTests.TEST1, '');
		assertMsg(check, MethodNameTests.TEST2, '');
		assertMsg(check, MethodNameTests.TEST3, '');
		assertMsg(check, MethodNameTests.TEST4, '');
		assertMsg(check, MethodNameTests.TEST5, '');
	}
}

class MethodNameTests {
	public static inline var TEST:String = "
	class Test {
		function test() {}
		function testName() {}
		public function testValue() {}
		public function get_Test() {}
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
