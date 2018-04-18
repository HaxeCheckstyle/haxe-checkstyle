package checks.coding;

import checkstyle.checks.coding.SimplifyBooleanReturnCheck;

class SimplifyBooleanReturnCheckTest extends CheckTestCase<SimplifyBooleanReturnCheckTests> {

	static inline var MSG_SIMPLIFY:String = "Conditional logic can be removed";

	@Test
	public function testWrongExpression() {
		assertMsg(new SimplifyBooleanReturnCheck(), TEST1, MSG_SIMPLIFY);
	}

	@Test
	public function testCorrectExpression() {
		assertNoMsg(new SimplifyBooleanReturnCheck(), TEST2);
	}

	@Test
	public function testOnlyIfExpression() {
		assertNoMsg(new SimplifyBooleanReturnCheck(), TEST3);
	}
}

@:enum
abstract SimplifyBooleanReturnCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		function test() {
			var a = (10 / 5 == 2);
			if (a) return false;
			else return true;
		}
	}";

	var TEST2 = "
	abstractAndClass Test {
		function test() {
			var a = (10 / 5 == 2);
			return a;
		}
	}";

	var TEST3 = "
	abstractAndClass Test {
		function test() {
			var a = (10 / 5 == 2);
			if (a) return false;
		}
	}";
}