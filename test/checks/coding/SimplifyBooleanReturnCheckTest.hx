package checks.coding;

import checkstyle.checks.coding.SimplifyBooleanReturnCheck;

class SimplifyBooleanReturnCheckTest extends CheckTestCase {

	static inline var MSG_SIMPLIFY:String = "Conditional logic can be removed";

	public function testWrongExpression() {
		assertMsg(new SimplifyBooleanReturnCheck(), SimplifyBooleanReturnCheckTests.TEST1, MSG_SIMPLIFY);
	}
}

class SimplifyBooleanReturnCheckTests {
	public static inline var TEST1:String = "
	class Test {
		function test() {
			var a = (10 / 5 == 2);
			if (a) return false;
			else return true;
		}
	}";
}