package checks.coding;

import checkstyle.checks.coding.ReturnCountCheck;

class ReturnCountCheckTest extends CheckTestCase<ReturnCountCheckTests> {

	public function testReturnCount() {
		assertMsg(new ReturnCountCheck(), TEST1, 'Return count is 3 (max allowed is 2)');
	}

	public function testCorrectReturnCount() {
		assertNoMsg(new ReturnCountCheck(), TEST2);
	}

	public function testSuppressedReturnCount() {
		assertNoMsg(new ReturnCountCheck(), TEST3);
	}

	public function testCustomReturnCount() {
		var chk = new ReturnCountCheck();
		chk.max = 1;
		assertMsg(chk, TEST4, 'Return count is 2 (max allowed is 1)');
	}

	public function testIgnoreRE() {
		var chk = new ReturnCountCheck();
		chk.ignoreFormat = "^equals$";
		assertMsg(chk, TEST5, '');
	}
}

@:enum
abstract ReturnCountCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		function a() {
			return 1;
			return 2;
			return 3;
		}
	}";

	var TEST2 = "
	abstractAndClass Test {
		function a() {
			return 1;
			if (true) {
				return 2;
			}
		}
	}";

	var TEST3 = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:ReturnCount')
		function a() {
			return 1;
			if (true) {
				return 2;
			}
			else return 3;
		}
	}";

	var TEST4 = "
	abstractAndClass Test {
		function a() {
			return 1;
			if (true) {
				return 2;
			}
		}
	}";

	var TEST5 = "
	abstractAndClass Test {
		function equals() {
			return 1;
			return 2;
			return 3;
		}
	}";
}