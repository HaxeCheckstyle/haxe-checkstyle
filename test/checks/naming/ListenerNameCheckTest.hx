package checks.naming;

import checkstyle.checks.naming.ListenerNameCheck;

class ListenerNameCheckTest extends CheckTestCase<ListenerNameCheckTests> {

	@Test
	public function testCorrectListenerName() {
		assertNoMsg(new ListenerNameCheck(), TEST);
	}

	@Test
	public function testListenerName1() {
		var check = new ListenerNameCheck();
		check.format = "^_?on.*";
		assertMsg(check, TEST1, 'Wrong listener name: "_testUpdate" (should be "~/${check.format}/")');
	}
}

@:enum
abstract ListenerNameCheckTests(String) to String {
	var TEST = "
	abstractAndClass Test {
		var a:Stage;
		public function new() {
			a.addOnce('update', _onUpdate);
		}

		function _onUpdate() {}
	}";

	var TEST1 = "
	abstractAndClass Test {
		var a:Stage;
		public function new() {
			a.addEventListener('update', _testUpdate);
		}

		function _testUpdate() {}
	}";
}