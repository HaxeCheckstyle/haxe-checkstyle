package ;

import checkstyle.checks.PublicPrivateCheck;

class PublicPrivateCheckTest extends CheckTestCase {

	public function testCorrectUsage() {
		var msg = checkMessage(PublicPrivateTests.TEST, new PublicPrivateCheck());
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
}