package ;

import checkstyle.checks.ListenerNameCheck;

class ListenerNameCheckTest extends CheckTestCase {

	public function testCorrectListenerName() {
		var msg = checkMessage(ListernerTests.TEST, new ListenerNameCheck());
		assertEquals(msg, '');
	}

	public function testListenerName1() {
		var msg = checkMessage(ListernerTests.TEST1, new ListenerNameCheck());
		assertEquals(msg, 'Wrong listener name, prefix with "on": _testUpdate');
	}

	public function testListenerName2() {
		var msg = checkMessage(ListernerTests.TEST2, new ListenerNameCheck());
		assertEquals(msg, 'Wrong listener name, prefix with "on": _testUpdate');
	}

	public function testListenerName3() {
		var msg = checkMessage(ListernerTests.TEST3, new ListenerNameCheck());
		assertEquals(msg, 'Wrong listener name, prefix with "on": _testUpdate');
	}
}

class ListernerTests {
	public static inline var TEST:String = "
	class Test {
		var a:Stage;
		public function new() {
			a.addOnce('update', _onUpdate);
		}

		function _onUpdate() {}
	}";

	public static inline var TEST1:String = "
	class Test {
		var a:Stage;
		public function new() {
			a.addEventListener('update', _testUpdate);
		}

		function _testUpdate() {}
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