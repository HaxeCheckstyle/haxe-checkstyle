package checkstyle.checks.coding;

class SwitchParenthesesCheckTest extends CheckTestCase<SwitchParenthesesCheckTests> {
	static inline var FORBID_MSG:String = "Switch condition should not be wrapped in parentheses";
	static inline var REQUIRE_MSG:String = "Switch condition should be wrapped in parentheses";

	@Test
	public function testWithParentheses() {
		assertMsg(new SwitchParenthesesCheck(), WITH_PARENTHESES, FORBID_MSG);
	}

	@Test
	public function testWithSpaceAndParentheses() {
		assertMsg(new SwitchParenthesesCheck(), WITH_SPACE_AND_PARENTHESES, FORBID_MSG);
	}

	@Test
	public function testWithoutParentheses() {
		assertNoMsg(new SwitchParenthesesCheck(), WITHOUT_PARENTHESES);
	}

	@Test
	public function testRequireWithParentheses() {
		var check = new SwitchParenthesesCheck();
		check.policy = REQUIRE;
		assertNoMsg(check, WITH_PARENTHESES);
	}

	@Test
	public function testRequireWithSpaceAndParentheses() {
		var check = new SwitchParenthesesCheck();
		check.policy = REQUIRE;
		assertNoMsg(check, WITH_SPACE_AND_PARENTHESES);
	}

	@Test
	public function testRequireWithoutParentheses() {
		var check = new SwitchParenthesesCheck();
		check.policy = REQUIRE;
		assertMsg(check, WITHOUT_PARENTHESES, REQUIRE_MSG);
	}
}

enum abstract SwitchParenthesesCheckTests(String) to String {
	var WITH_PARENTHESES = "
	abstractAndClass Test {
		function check(value:Int):Int {
			switch(value) {
				case 0: return 1;
				default: return 2;
			}
		}
	}";

	var WITH_SPACE_AND_PARENTHESES = "
	abstractAndClass Test {
		function check(value:Int):Int {
			switch (value) {
				case 0: return 1;
				default: return 2;
			}
		}
	}";

	var WITHOUT_PARENTHESES = "
	abstractAndClass Test {
		function check(value:Int):Int {
			switch value {
				case 0: return 1;
				default: return 2;
			}
		}
	}";
}
