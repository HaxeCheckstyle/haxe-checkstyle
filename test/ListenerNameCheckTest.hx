package ;

import checkstyle.checks.ListenerNameCheck;

class ListenerNameCheckTest extends CheckTestCase {

	public function testCorrectListenerName() {
		var check = new ListenerNameCheck();
		var msg = checkMessage(ListernerTests.TEST, check);
		assertEquals(msg, '');
	}

	public function testListenerName1() {
		var check = new ListenerNameCheck();
		check.format = "^_?on.*";
		var msg = checkMessage(ListernerTests.TEST1, check);
		assertEquals(msg, 'Wrong listener name: _testUpdate (should be ~/^_?on.*/)');
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
}