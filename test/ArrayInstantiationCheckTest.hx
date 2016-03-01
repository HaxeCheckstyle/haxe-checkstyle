package;

import checkstyle.checks.ArrayInstantiationCheck;

class ArrayInstantiationCheckTest extends CheckTestCase {

	public function testWrongArrayInstantiation() {
		assertMsg(new ArrayInstantiationCheck(), ArrayInstantiationTests.TEST1, 'Bad array instantiation, use the array literal notation [] which is faster');
	}

	public function testCorrectArrayInstantiation() {
		assertMsg(new ArrayInstantiationCheck(), ArrayInstantiationTests.TEST2, '');
	}
}

class ArrayInstantiationTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		var _arr:Array<Int> = new Array<Int>();
	}";

	public static inline var TEST2:String = "
	abstractAndClass Test {
		var _arr:Array<Int> = [];
	}";
}