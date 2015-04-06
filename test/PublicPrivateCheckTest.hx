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
	class Test {
		var a:Stage;
		public function new() {
			a.on('update', _testUpdate);
		}

		function _testUpdate() {}
	}";

	public static inline var TEST3:String = "
	class Test {
		var a:Stage;
		public function new() {
			a.once('update', _testUpdate);
		}

		function _testUpdate() {}
	}";
}