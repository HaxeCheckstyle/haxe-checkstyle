package checks.coding;

import checkstyle.checks.coding.SimplifyBooleanExpressionCheck;

class SimplifyBooleanExpressionCheckTest extends CheckTestCase {

	public function testWrongExpression() {
		assertMsg(new SimplifyBooleanExpressionCheck(), SimplifyBooleanExpressionCheckTests.TEST1, 'Boolean expression can be simplified');
		assertMsg(new SimplifyBooleanExpressionCheck(), SimplifyBooleanExpressionCheckTests.TEST2, 'Boolean expression can be simplified');
		assertMsg(new SimplifyBooleanExpressionCheck(), SimplifyBooleanExpressionCheckTests.TEST3, 'Boolean expression can be simplified');
		assertMsg(new SimplifyBooleanExpressionCheck(), SimplifyBooleanExpressionCheckTests.TEST4, 'Boolean expression can be simplified');
	}

	public function testCorrectExpression() {
		assertMsg(new SimplifyBooleanExpressionCheck(), SimplifyBooleanExpressionCheckTests.TEST5, '');
		assertMsg(new SimplifyBooleanExpressionCheck(), SimplifyBooleanExpressionCheckTests.TEST6, '');
	}
}

class SimplifyBooleanExpressionCheckTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (bvar == true) {}
		}
	}";

	public static inline var TEST2:String = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (bvar || true) {}
		}
	}";

	public static inline var TEST3:String = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (bvar != true) {}
		}
	}";

	public static inline var TEST4:String = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (!false) {}
		}
	}";

	public static inline var TEST5:String = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (bvar) {}
		}
	}";

	public static inline var TEST6:String = "
	abstractAndClass Test {
		function test() {
			var bvar:Bool;
			if (!bvar) {}
		}
	}";
}