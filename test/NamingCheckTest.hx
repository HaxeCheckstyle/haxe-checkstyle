package ;

import checkstyle.checks.NamingCheck;

class NamingCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var msg = checkMessage(NamingTests.TEST, new NamingCheck());
		assertEquals(msg, '');
	}

	public function testLocalVar1() {
		var msg = checkMessage(NamingTests.TEST1, new NamingCheck());
		assertEquals(msg, 'Invalid local variable signature: COUNT (name should be camelCase)');
	}

	public function testLocalVar2() {
		var msg = checkMessage(NamingTests.TEST2, new NamingCheck());
		assertEquals(msg, 'Invalid local variable signature: Count (name should be camelCase)');
	}

	public function testPrivateVar1() {
		var msg = checkMessage(NamingTests.TEST3, new NamingCheck());
		assertEquals(msg, 'Invalid private signature: a (name should be camelCase starting with underscore)');
	}

	public function testPrivateVar2() {
		var msg = checkMessage(NamingTests.TEST4, new NamingCheck());
		assertEquals(msg, 'Invalid private signature: _Count (name should be camelCase starting with underscore)');
	}

	public function testPrivateVarUnderscoreConfiguration() {
		var check = new NamingCheck();
		check.privateUnderscorePrefix = false;
		var msg = checkMessage(NamingTests.TEST3, check);
		assertEquals(msg, '');
	}

	public function testPublicVar1() {
		var msg = checkMessage(NamingTests.TEST5, new NamingCheck());
		assertEquals(msg, 'Invalid public signature: Count (name should be camelCase)');
	}

	public function testConstantVar1() {
		var msg = checkMessage(NamingTests.TEST6, new NamingCheck());
		assertEquals(msg, 'Inline constant variables should be uppercase: Count');
	}

	public function testConstantVar2() {
		var msg = checkMessage(NamingTests.TEST7, new NamingCheck());
		assertEquals(msg, 'Inline constant variables should be uppercase: _COUNT');
	}
}

class NamingTests {
	public static inline var TEST:String = "
	class Test {
		var _a:Int;
		var _myName:String;

		public var a:Int;
		var _myName:String;
	}";

	public static inline var TEST1:String = "
	class Test {
		public function test() {
			var COUNT:Int;
		}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function test() {
			var Count:Int;
		}
	}";

	public static inline var TEST3:String =
	"class Test {
		var a:Int;
	}";

	public static inline var TEST4:String =
	"class Test {
		var _Count:Int;
	}";

	public static inline var TEST5:String =
	"class Test {
		public var Count:Int;
	}";

	public static inline var TEST6:String =
	"class Test {
		static inline var Count:Int = 5;
	}";

	public static inline var TEST7:String =
	"class Test {
		static inline var _COUNT:Int = 5;
	}";
}