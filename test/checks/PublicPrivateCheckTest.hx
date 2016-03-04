package checks;

import checkstyle.checks.PublicPrivateCheck;

class PublicPrivateCheckTest extends CheckTestCase {

	public function testCorrectUsage() {
		assertMsg(new PublicPrivateCheck(), PublicPrivateTests.TEST, '');
		assertMsg(new PublicPrivateCheck(), PublicPrivateTests.TEST3, '');
	}

	public function testNormalClass() {
		assertMsg(new PublicPrivateCheck(), PublicPrivateTests.TEST1, 'No need of private keyword: a (fields are by default private in classes)');
	}

	public function testInterface() {
		assertMsg(new PublicPrivateCheck(), PublicPrivateTests.TEST2, 'No need of public keyword: a (fields are by default public in interfaces)');
	}

	public function testClassWithEnforce() {
		var check = new PublicPrivateCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, PublicPrivateTests.TEST1, '');
	}

	public function testClassWithEnforceMissing() {
		var check = new PublicPrivateCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, PublicPrivateTests.TEST, 'Missing private keyword: _onUpdate');
	}

	public function testInterfaceWithEnforce() {
		var check = new PublicPrivateCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, PublicPrivateTests.TEST2, '');
	}

	public function testInterfaceWithEnforceMissing() {
		var check = new PublicPrivateCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, PublicPrivateTests.TEST3, 'Missing public keyword: a');
	}
}

class PublicPrivateTests {
	public static inline var TEST:String = "
	abstractAndClass Test {
		var a:Int;
		public function new() {}

		function _onUpdate() {}

		public function test(){}
	}";

	public static inline var TEST1:String = "
	abstractAndClass Test {
		private var a:Int;

		public function new() {}
	}";

	public static inline var TEST2:String = "
	interface Test {
		public var a:Int;
	}";

	public static inline var TEST3:String = "
	interface Test {
		var a:Int;
	}";
}