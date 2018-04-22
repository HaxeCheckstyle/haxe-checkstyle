package checks.coding;

import checkstyle.checks.coding.NestedTryDepthCheck;

class NestedTryDepthCheckTest extends CheckTestCase<NestedTryDepthCheckTests> {

	@Test
	public function testDefault() {
		var check = new NestedTryDepthCheck();
		assertNoMsg(check, TEST1);
	}

	@Test
	public function testDefaultTooMany() {
		var check = new NestedTryDepthCheck();
		assertMsg(check, TEST2, "Nested try depth is 2 (max allowed is 1)");
	}

	@Test
	public function testMaxParameter() {
		var check = new NestedTryDepthCheck();
		check.max = 2;

		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);

		check.max = 0;
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, "Nested try depth is 1 (max allowed is 0)");
	}
}

@:enum
abstract NestedTryDepthCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		public function test() {
			try { } catch(e:String) { }    // level 0
			try {                          // level 0
				throw 'test';
			} catch(e:String) {
			}
		}

		@SuppressWarnings('checkstyle:NestedTryDepth')
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

	var TEST2 = "
	abstractAndClass Test {
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