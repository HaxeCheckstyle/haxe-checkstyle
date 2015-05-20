package ;

import checkstyle.checks.NestedForDepthCheck;

class NestedForDepthCheckTest extends CheckTestCase {

	public function testDefault() {
		var msg = checkMessage(NestedForDepthTests.TEST1, new NestedForDepthCheck());
		assertEquals('', msg);
	}

	public function testDefaultTooMany() {
		var msg = checkMessage(NestedForDepthTests.TEST2, new NestedForDepthCheck());
		assertEquals('Nested for depth is 2 (max allowed is 1)', msg);
	}

	public function testMaxParameter() {
		var check = new NestedForDepthCheck();
		check.max = 2;

		var msg = checkMessage(NestedForDepthTests.TEST1, check);
		assertEquals('', msg);

		msg = checkMessage(NestedForDepthTests.TEST2, check);
		assertEquals('', msg);

		check.max = 0;

		msg = checkMessage(NestedForDepthTests.TEST1, check);
		assertEquals('', msg);

		msg = checkMessage(NestedForDepthTests.TEST2, check);
		assertEquals('Nested for depth is 1 (max allowed is 0)', msg);
	}
}

class NestedForDepthTests {
	public static inline var TEST1:String = "
	class Test {
		public function test(params:Array<Int>):Void {
			for (param in params) trace(param);               // level 0
			for (i in 0...params.length) {                    // level 0
				trace ('$i ${params[i]}');
			}
		}
	}";

	public static inline var TEST2:String =
	"class Test {
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
