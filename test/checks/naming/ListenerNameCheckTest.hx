package checks.naming;

import checkstyle.checks.naming.ListenerNameCheck;

class ListenerNameCheckTest extends CheckTestCase {

	public function testCorrectListenerName() {
		assertNoMsg(new ListenerNameCheck(), ListernerTests.TEST);
	}

	public function testListenerName1() {
		var check = new ListenerNameCheck();
		check.format = "^_?on.*";
		assertMsg(check, ListernerTests.TEST1, 'Wrong listener name: _testUpdate (should be ~/${check.format}/)');
	}
}

class ListernerTests {
	public static inline var TEST:String = "
	abstractAndClass Test {
		var a:Stage;
		public function new() {
			a.addOnce('update', _onUpdate);
		}

		function _onUpdate() {}
	}";

	public static inline var TEST1:String = "
	abstractAndClass Test {
		var a:Stage;
		public function new() {
			a.addEventListener('update', _testUpdate);
		}

		function _testUpdate() {}
	}";
}