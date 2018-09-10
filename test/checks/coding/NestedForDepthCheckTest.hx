package checks.coding;

import checkstyle.checks.coding.NestedForDepthCheck;

class NestedForDepthCheckTest extends CheckTestCase<NestedForDepthCheckTests> {
	@Test
	public function testDefault() {
		var check = new NestedForDepthCheck();
		assertNoMsg(check, TEST1);
	}

	@Test
	public function testDefaultTooMany() {
		var check = new NestedForDepthCheck();
		assertMsg(check, TEST2, "Nested loop depth is 2 (max allowed is 1)");
	}

	@Test
	public function testMaxParameter() {
		var check = new NestedForDepthCheck();
		check.max = 2;

		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);

		check.max = 0;
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, "Nested loop depth is 1 (max allowed is 0)");
	}
}

@:enum
abstract NestedForDepthCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		public function test(params:Array<Int>):Void {
			for (param in params) trace(param);               // level 0
			for (i in 0...params.length) {                    // level 0
				trace ('$i ${params[i]}');
			}
		}

		@SuppressWarnings('checkstyle:NestedForDepth')
		public function test2(param:Array<Int>) {
			for (outerParam in params) {                      // level 0
				for (middleParam in params) {                 // level 1
					for (innerParam in params) {              // level 2
						if (outerParam == innerParam) {
							trace (param);
						}
					}
				}
			}
		}
	}

	@SuppressWarnings('checkstyle:NestedForDepth')
	abstractAndClass Test2 {
		public function test2(param:Array<Int>) {
			for (outerParam in params) {                      // level 0
				for (middleParam in params) {                 // level 1
					for (innerParam in params) {              // level 2
						if (outerParam == innerParam) {
							trace (param);
						}
					}
				}
			}
		}
	}";
	var TEST2 = "
	abstractAndClass Test {
		public function test1(param:Array<Int>) {
			for (outerParam in params) {                      // level 0
				for (middleParam in params) {                 // level 1
					for (innerParam in params) {              // level 2
						if (outerParam == innerParam) {
							trace (param);
						}
					}
				}
			}
		}
	}";
}