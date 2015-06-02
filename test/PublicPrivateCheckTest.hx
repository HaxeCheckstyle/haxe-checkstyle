package ;

import checkstyle.checks.PublicPrivateCheck;

class PublicPrivateCheckTest extends CheckTestCase {

	public function testCorrectUsage() {
		var msg = checkMessage(PublicPrivateTests.TEST, new PublicPrivateCheck());
		assertEquals(msg, '');
		msg = checkMessage(PublicPrivateTests.TEST3, new PublicPrivateCheck());
		assertEquals(msg, '');
	}

	public function testNormalClass() {
		var msg = checkMessage(PublicPrivateTests.TEST1, new PublicPrivateCheck());
		assertEquals(msg, 'No need of private keyword: a (fields are by default private in classes)');
	}

	public function testInterface() {
		var msg = checkMessage(PublicPrivateTests.TEST2, new PublicPrivateCheck());
		assertEquals(msg, 'No need of public keyword: a (fields are by default public in interfaces)');
	}

	public function testClassWithEnforce() {
		var check = new PublicPrivateCheck ();
		check.enforcePublicPrivate = true;
		var msg = checkMessage(PublicPrivateTests.TEST1, check);
		assertEquals(msg, '');
	}

	public function testClassWithEnforceMissing() {
		var check = new PublicPrivateCheck ();
		check.enforcePublicPrivate = true;
		var msg = checkMessage(PublicPrivateTests.TEST, check);
		assertEquals(msg, 'Missing private keyword: _onUpdate');
	}

	public function testInterfaceWithEnforce() {
		var check = new PublicPrivateCheck ();
		check.enforcePublicPrivate = true;
		var msg = checkMessage(PublicPrivateTests.TEST2, check);
		assertEquals(msg, '');
	}

	public function testInterfaceWithEnforceMissing() {
		var check = new PublicPrivateCheck ();
		check.enforcePublicPrivate = true;
		var msg = checkMessage(PublicPrivateTests.TEST3, check);
		assertEquals(msg, 'Missing public keyword: a');
	}
}

class PublicPrivateTests {
	public static inline var TEST:String = "
	class Test {
		var a:Int;
		public function new() {}

		function _onUpdate() {}

		public function test(){}
	}";

	public static inline var TEST1:String = "
	class Test {
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