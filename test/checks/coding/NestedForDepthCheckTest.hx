package checks.coding;

import checkstyle.checks.coding.NestedForDepthCheck;

class NestedForDepthCheckTest extends CheckTestCase {

	public function testDefault() {
		var check = new NestedForDepthCheck();
		assertMsg(check, NestedForDepthTests.TEST1, '');
	}

	public function testDefaultTooMany() {
		var check = new NestedForDepthCheck();
		assertMsg(check, NestedForDepthTests.TEST2, 'Nested for depth is 2 (max allowed is 1)');
	}

	public function testMaxParameter() {
		var check = new NestedForDepthCheck();
		check.max = 2;

		assertMsg(check, NestedForDepthTests.TEST1, '');
		assertMsg(check, NestedForDepthTests.TEST2, '');

		check.max = 0;
		assertMsg(check, NestedForDepthTests.TEST1, '');
		assertMsg(check, NestedForDepthTests.TEST2, 'Nested for depth is 1 (max allowed is 0)');
	}
}

class NestedForDepthTests {
	public static inline var TEST1:String = "
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

	public static inline var TEST2:String =
	"abstractAndClass Test {
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