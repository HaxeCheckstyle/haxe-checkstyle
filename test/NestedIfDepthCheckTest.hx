package ;

import checkstyle.checks.NestedIfDepthCheck;

class NestedIfDepthCheckTest extends CheckTestCase {

	public function testDefault() {
		var check = new NestedIfDepthCheck();
		assertMsg(check, NestedIfDepthTests.TEST1, '');
	}

	public function testDefaultTooMany() {
		var check = new NestedIfDepthCheck();
		assertMsg(check, NestedIfDepthTests.TEST2, 'Nested if-else depth is 2 (max allowed is 1)');
	}

	public function testMaxParameter() {
		var check = new NestedIfDepthCheck();
		check.max = 2;

		assertMsg(check, NestedIfDepthTests.TEST1, '');
		assertMsg(check, NestedIfDepthTests.TEST2, '');

		check.max = 0;
		assertMsg(check, NestedIfDepthTests.TEST1, '');
		assertMsg(check, NestedIfDepthTests.TEST2, 'Nested if-else depth is 1 (max allowed is 0)');
	}
}

class NestedIfDepthTests {
	public static inline var TEST1:String = "
	class Test {
		public function test(param:Int):Void {
			if (param == 0) return 0;                   // level 0
			if (param == 1) {                           // level 0
				return 1;
			}
			else {
				return 2;
			}
		}

		@SuppressWarnings('checkstyle:NestedIfDepth')
		public function test1(param:Int) {
			if (param == 1) {                           // level 0
				return 1;
			}
			else {
				if ((param == 2) || (param == 3)) {     // level 1
					if (param == 3) return 3;           // level 2
					return 2;
				}
			}
			return 3;
		}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function test1(param:Int) {
			if (param == 1) {                           // level 0
				return 1;
			}
			else {
				if ((param == 2) || (param == 3)) {     // level 1
					if (param == 3) return 3;           // level 2
					return 2;
				}
			}
			return 3;
		}
	}";
}