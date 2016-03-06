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
}