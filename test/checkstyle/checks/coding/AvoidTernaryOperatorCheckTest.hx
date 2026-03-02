package checkstyle.checks.coding;

import checkstyle.SeverityLevel;

class AvoidTernaryOperatorCheckTest extends CheckTestCase<AvoidTernaryOperatorCheckTests> {
	@Test
	public function testTernaryDepth0() {
		var check = new AvoidTernaryOperatorCheck();
		check.severity = SeverityLevel.INFO;

		check.maxDepth = 0;

		assertMsg(check, TEST_VAR, "Avoid use of ternary operators");
		assertMsg(check, TEST_FUNC, "Avoid use of ternary operators");
		assertMessages(check, TEST_NESTED, [
			"Avoid use of ternary operators",
			"Avoid use of ternary operators"
		]);
		assertMsg(check, TEST_DOUBLE_NESTED, "Avoid use of ternary operators");
	}

	@Test
	public function testTernaryDepth1() {
		var check = new AvoidTernaryOperatorCheck();
		check.severity = SeverityLevel.INFO;

		check.maxDepth = 1;

		assertNoMsg(check, TEST_VAR);
		assertNoMsg(check, TEST_FUNC);
		assertMessages(check, TEST_NESTED, [
			"Maximum ternary depth exceeded",
			"Maximum ternary depth exceeded",
			"Maximum ternary depth exceeded",
			"Maximum ternary depth exceeded"
		]);
		assertMessages(check, TEST_DOUBLE_NESTED, [
			"Maximum ternary depth exceeded",
			"Maximum ternary depth exceeded"
		]);
	}

	@Test
	public function testTernaryDepth2() {
		var check = new AvoidTernaryOperatorCheck();
		check.severity = SeverityLevel.INFO;

		check.maxDepth = 2;

		assertNoMsg(check, TEST_VAR);
		assertNoMsg(check, TEST_FUNC);
		assertNoMsg(check, TEST_NESTED);
		assertMsg(check, TEST_DOUBLE_NESTED, "Maximum ternary depth exceeded");
	}
}

enum abstract AvoidTernaryOperatorCheckTests(String) to String {
	var TEST_VAR = "
	abstractAndClass Test {
		var a:Array<Int> = [];
		var x = (a == null || a.length < 1) ? null : a[0];
	}";

	var TEST_FUNC = "
	abstractAndClass Test {
		function test() {
			var result = (foo) ? (bar) : (baz);
		}
	}
	";

	var TEST_NESTED = "
	abstractAndClass Test {
		var result = foo ? (bar ? baz : null) : (bar ? baz : null);
		var result = foo ? bar ? baz : null : bar ? baz : null;
	}
	";

	var TEST_DOUBLE_NESTED = "
	abstractAndClass Test {
		var result = foo ? (bar ? baz : (hello ? world : null)) : (bar ? baz : null);
	}
	";
}