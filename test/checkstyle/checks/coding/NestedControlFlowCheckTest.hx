package checkstyle.checks.coding;

class NestedControlFlowCheckTest extends CheckTestCase<NestedControlFlowCheckTests> {
	@Test
	public function testDefault() {
		var check = new NestedControlFlowCheck();
		assertNoMsg(check, COMPLIANT_NESTING);
	}

	@Test
	public function testDefaultTooMany() {
		var check = new NestedControlFlowCheck();
		assertMsg(check, TOO_MANY_FORS, "Nested control flow depth is 4 (max allowed is 3)");
		assertMsg(check, NESTED_IF_FOR, "Nested control flow depth is 4 (max allowed is 3)");
		assertMsg(check, NESTED_TRY_SWITCH_WHILE, "Nested control flow depth is 4 (max allowed is 3)");
		assertMsg(check, NESTED_TRY_SWITCH_DO_WHILE, "Nested control flow depth is 4 (max allowed is 3)");
	}

	@Test
	public function testMaxParameter() {
		var check = new NestedControlFlowCheck();
		check.max = 4;

		assertNoMsg(check, COMPLIANT_NESTING);
		assertNoMsg(check, TOO_MANY_FORS);
		assertNoMsg(check, NESTED_IF_FOR);
		assertNoMsg(check, NESTED_TRY_SWITCH_WHILE);
		assertNoMsg(check, NESTED_TRY_SWITCH_DO_WHILE);

		check.max = 1;
		assertNoMsg(check, COMPLIANT_NESTING);
		assertMessages(check, TOO_MANY_FORS, [
			"Nested control flow depth is 2 (max allowed is 1)",
			"Nested control flow depth is 3 (max allowed is 1)",
			"Nested control flow depth is 4 (max allowed is 1)"
		]);
	}
}

@:enum
abstract NestedControlFlowCheckTests(String) to String {
	var COMPLIANT_NESTING = "
	abstractAndClass Test {
		public function test(param:Int):Void {
			if (param == 0) return 0;                   // level 0
			if (param == 1) {                           // level 0
				return 1;
			}
			else {
				return 2;
			}
			for (outerParam in params) trace(outerParam);
		}

		@SuppressWarnings('checkstyle:NestedControlFlow')
		public function test1(param:Int) {
			for (outerParam in params) {                      // level 1
				for (middleParam in params) {                 // level 2
					for (innerParam in params) {              // level 3
						if (outerParam == innerParam) {       // level 4
							trace (param);
						}
					}
				}
			}
		}
	}";
	var TOO_MANY_FORS = "
	abstractAndClass Test {
		public function test1(param:Int) {
			for (outerParam in params) {                      // level 1
				for (middleParam in params) {                 // level 2
					for (innerParam in params) {              // level 3
						if (innerParam == null) {             // level 4
						}
					}
				}
			}
		}
	}";
	var NESTED_IF_FOR = "
	abstractAndClass Test {
		public function test1(param:Int) {
			if (outerParam != null) {                         // level 1
				for (middleParam in params) {                 // level 2
					if (innerParam == null) {                 // level 3
						if (innerParam == null) {             // level 4
						}
					}
				}
			}
		}
	}";
	var NESTED_TRY_SWITCH_WHILE = "
	abstractAndClass Test {
		public function test1(param:Int) {
			try {                                             // level 1
				switch (param) {                              // level 2
					case 1:
						while (true) {                        // level 3
							if (outerParam == innerParam) {   // level 4
								trace (param);
							}
						}
				}
			}
			catch (e:Any) {}
		}
	}";
	var NESTED_TRY_SWITCH_DO_WHILE = "
	abstractAndClass Test {
		public function test1(param:Int) {
			try {                                             // level 1
				switch (param) {                              // level 2
					case 1:
						do {                                  // level 3
							if (outerParam == innerParam) {   // level 4
								trace (param);
							}
						}
						while (true);
				}
			}
			catch (e:Any) {}
		}
	}";
}