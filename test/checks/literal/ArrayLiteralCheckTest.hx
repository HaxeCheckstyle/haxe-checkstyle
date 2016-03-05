package checks.literal;

import checkstyle.checks.literal.ArrayLiteralCheck;

class ArrayLiteralCheckTest extends CheckTestCase {

	public function testWrongArrayInstantiation() {
		assertMsg(new ArrayLiteralCheck(), ArrayLiteralTests.TEST1, 'Bad array instantiation, use the array literal notation [] which is shorter and cleaner');
	}

	public function testCorrectArrayInstantiation() {
		assertNoMsg(new ArrayLiteralCheck(), ArrayLiteralTests.TEST2);
	}
}

class ArrayLiteralTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		var _arr:Array<Int> = new Array<Int>();
	}";

	public static inline var TEST2:String = "
	abstractAndClass Test {
		var _arr:Array<Int> = [];
	}";
}