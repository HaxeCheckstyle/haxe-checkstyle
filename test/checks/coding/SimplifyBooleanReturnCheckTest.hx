package checks.coding;

import checkstyle.checks.coding.SimplifyBooleanReturnCheck;

class SimplifyBooleanReturnCheckTest extends CheckTestCase {

	static inline var MSG_SIMPLIFY:String = "Conditional logic can be removed";

	public function testWrongExpression() {
		assertMsg(new SimplifyBooleanReturnCheck(), SimplifyBooleanReturnCheckTests.TEST1, MSG_SIMPLIFY);
	}

	public function testCorrectExpression() {
		assertNoMsg(new SimplifyBooleanReturnCheck(), SimplifyBooleanReturnCheckTests.TEST2);
	}

	public function testOnlyIfExpression() {
		assertNoMsg(new SimplifyBooleanReturnCheck(), SimplifyBooleanReturnCheckTests.TEST3);
	}
}

class SimplifyBooleanReturnCheckTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		function test() {
			var a = (10 / 5 == 2);
			if (a) return false;
			else return true;
		}
	}";

	public static inline var TEST2:String = "
	abstractAndClass Test {
		function test() {
			var a = (10 / 5 == 2);
			return a;
		}
	}";

	public static inline var TEST3:String = "
	abstractAndClass Test {
		function test() {
			var a = (10 / 5 == 2);
			if (a) return false;
		}
	}";
}