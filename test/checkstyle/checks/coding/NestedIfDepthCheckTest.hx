package checkstyle.checks.coding;

class NestedIfDepthCheckTest extends CheckTestCase<NestedIfDepthCheckTests> {
	@Test
	public function testDefault() {
		var check = new NestedIfDepthCheck();
		assertNoMsg(check, TEST1);
	}

	@Test
	public function testDefaultTooMany() {
		var check = new NestedIfDepthCheck();
		assertMsg(check, TEST2, "Nested if-else depth is 2 (max allowed is 1)");
	}

	@Test
	public function testMaxParameter() {
		var check = new NestedIfDepthCheck();
		check.max = 2;

		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);

		check.max = 0;
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, "Nested if-else depth is 1 (max allowed is 0)");
	}
}

@:enum
abstract NestedIfDepthCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
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
	var TEST2 = "
	abstractAndClass Test {
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