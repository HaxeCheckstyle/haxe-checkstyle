package ;

import checkstyle.checks.NestedTryDepthCheck;

class NestedTryDepthCheckTest extends CheckTestCase {

	public function testDefault() {
		var msg = checkMessage(NestedTryDepthTests.TEST1, new NestedTryDepthCheck());
		assertEquals('', msg);
	}

	public function testDefaultTooMany() {
		var msg = checkMessage(NestedTryDepthTests.TEST2, new NestedTryDepthCheck());
		assertEquals('Nested try depth is 2 (max allowed is 1)', msg);
	}

	public function testMaxParameter() {
		var check = new NestedTryDepthCheck();
		check.max = 2;

		var msg = checkMessage(NestedTryDepthTests.TEST1, check);
		assertEquals('', msg);

		msg = checkMessage(NestedTryDepthTests.TEST2, check);
		assertEquals('', msg);

		check.max = 0;

		msg = checkMessage(NestedTryDepthTests.TEST1, check);
		assertEquals('', msg);

		msg = checkMessage(NestedTryDepthTests.TEST2, check);
		assertEquals('Nested try depth is 1 (max allowed is 0)', msg);
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
