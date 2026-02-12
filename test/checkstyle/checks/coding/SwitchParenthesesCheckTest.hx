package checkstyle.checks.coding;

import checkstyle.checks.coding.SwitchParenthesesCheck.SwitchParenthesesPolicy;

class SwitchParenthesesCheckTest extends CheckTestCase<SwitchParenthesesCheckTests> {
	static inline var FORBID_MSG:String = "Switch condition should not be wrapped in parentheses";
	static inline var REQUIRE_MSG:String = "Switch condition should be wrapped in parentheses";

	function configuredCheck(policy:SwitchParenthesesPolicy):SwitchParenthesesCheck {
		var check = new SwitchParenthesesCheck();
		check.policy = policy;
		return check;
	}

	@Test
	public function testWithParentheses() {
		assertMsg(configuredCheck(FORBID), WITH_PARENTHESES, FORBID_MSG);
	}

	@Test
	public function testWithSpaceAndParentheses() {
		assertMsg(configuredCheck(FORBID), WITH_SPACE_AND_PARENTHESES, FORBID_MSG);
	}

	@Test
	public function testWithoutParentheses() {
		assertNoMsg(configuredCheck(FORBID), WITHOUT_PARENTHESES);
	}

	@Test
	public function testRequireWithParentheses() {
		assertNoMsg(configuredCheck(REQUIRE), WITH_PARENTHESES);
	}

	@Test
	public function testRequireWithSpaceAndParentheses() {
		assertNoMsg(configuredCheck(REQUIRE), WITH_SPACE_AND_PARENTHESES);
	}

	@Test
	public function testRequireWithoutParentheses() {
		assertMsg(configuredCheck(REQUIRE), WITHOUT_PARENTHESES, REQUIRE_MSG);
	}

	@Test
	public function testIgnoreByDefault() {
		assertNoMsg(new SwitchParenthesesCheck(), WITH_PARENTHESES);
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
