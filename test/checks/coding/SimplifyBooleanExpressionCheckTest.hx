package checks.coding;

import checkstyle.checks.coding.SimplifyBooleanExpressionCheck;

class SimplifyBooleanExpressionCheckTest extends CheckTestCase<SimplifyBooleanExpressionCheckTests> {

	static inline var MSG_SIMPLIFY:String = "Boolean expression can be simplified";

	@Test
	public function testWrongExpression() {
		assertMsg(new SimplifyBooleanExpressionCheck(), TEST1, MSG_SIMPLIFY);
		assertMsg(new SimplifyBooleanExpressionCheck(), TEST2, MSG_SIMPLIFY);
		assertMsg(new SimplifyBooleanExpressionCheck(), TEST3, MSG_SIMPLIFY);
		assertMsg(new SimplifyBooleanExpressionCheck(), TEST4, MSG_SIMPLIFY);
	}

	@Test
	public function testCorrectExpression() {
		assertNoMsg(new SimplifyBooleanExpressionCheck(), TEST5);
		assertNoMsg(new SimplifyBooleanExpressionCheck(), TEST6);
	}

	@Test
	public function testSuppressExpression() {
		assertNoMsg(new SimplifyBooleanExpressionCheck(), TEST7);
	}
}

@:enum
abstract SimplifyBooleanExpressionCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (bvar == true) {}
		}
	}";

	var TEST2 = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (bvar || true) {}
		}
	}";

	var TEST3 = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (bvar != true) {}
		}
	}";

	var TEST4 = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (!false) {}
		}
	}";

	var TEST5 = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (bvar) {}
		}
	}";

	var TEST6 = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (!bvar) {}
		}
	}";

	var TEST7 = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:SimplifyBooleanExpression')
		public static function main() {
			var value: Null<Bool> = null;
			trace(value == true);
		}
	}";
}