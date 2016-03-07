package checks.coding;

import checkstyle.checks.coding.ReturnCountCheck;

class ReturnCountCheckTest extends CheckTestCase {

	public function testReturnCount() {
		assertMsg(new ReturnCountCheck(), ReturnCountCheckTests.TEST1, 'Return count is 3 (max allowed is 2)');
	}

	public function testCorrectReturnCount() {
		assertNoMsg(new ReturnCountCheck(), ReturnCountCheckTests.TEST2);
	}

	public function testSuppressedReturnCount() {
		assertNoMsg(new ReturnCountCheck(), ReturnCountCheckTests.TEST3);
	}

	public function testCustomReturnCount() {
		var chk = new ReturnCountCheck();
		chk.max = 1;
		assertMsg(chk, ReturnCountCheckTests.TEST4, 'Return count is 2 (max allowed is 1)');
	}

	public function testIgnoreRE() {
		var chk = new ReturnCountCheck();
		chk.ignoreFormat = "^equals$";
		assertMsg(chk, ReturnCountCheckTests.TEST5, '');
	}
}

class ReturnCountCheckTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		function a() {
			return 1;
			return 2;
			return 3;
		}
	}";

	public static inline var TEST2:String = "
	abstractAndClass Test {
		function a() {
			return 1;
			if (true) {
				return 2;
			}
		}
	}";

	public static inline var TEST3:String = "
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

	public static inline var TEST4:String = "
	abstractAndClass Test {
		function a() {
			return 1;
			if (true) {
				return 2;
			}
		}
	}";

	public static inline var TEST5:String = "
	abstractAndClass Test {
		function equals() {
			return 1;
			return 2;
			return 3;
		}
	}";
}