package ;

import checkstyle.checks.NestedTryDepthCheck;

class NestedTryDepthCheckTest extends CheckTestCase {

	public function testDefault() {
		var check = new NestedTryDepthCheck();
		assertMsg(check, NestedTryDepthTests.TEST1, '');
	}

	public function testDefaultTooMany() {
		var check = new NestedTryDepthCheck();
		assertMsg(check, NestedTryDepthTests.TEST2, 'Nested try depth is 2 (max allowed is 1)');
	}

	public function testMaxParameter() {
		var check = new NestedTryDepthCheck();
		check.max = 2;

		assertMsg(check, NestedTryDepthTests.TEST1, '');
		assertMsg(check, NestedTryDepthTests.TEST2, '');

		check.max = 0;
		assertMsg(check, NestedTryDepthTests.TEST1, '');
		assertMsg(check, NestedTryDepthTests.TEST2, 'Nested try depth is 1 (max allowed is 0)');
	}
}

class NestedTryDepthTests {
	public static inline var TEST1:String = "
	class Test {
		public function test() {
			try { } catch(e:String) { }    // level 0
			try {                          // level 0
				throw 'test';
			} catch(e:String) {
			}
		}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function test1() {
			try {                           // level 0
				try {                       // level 0
					throw 'test';
				} catch(e:String) {
					throw 'test';
				}
			} catch(e:String) {
				try {                       // level 1
				} catch(e1:String) {
					try {                   // level 2
					} catch(e1:String) {
					}
				}
			} catch(e1:Int) {
				try {                       // level 1
				} catch(e2:String) {
				}
			}
		}
	}";
}
