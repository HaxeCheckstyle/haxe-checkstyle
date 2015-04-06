package ;

import checkstyle.checks.ArrayInstantiationCheck;

class ArrayInstantiationCheckTest extends CheckTestCase {

	public function testWrongArrayInstantiation() {
		var msg = checkMessage(ArrayInstantiationTests.TEST1, new ArrayInstantiationCheck());
		assertEquals(msg, 'Bad array instantiation, use the array literal notation [] which is faster');
	}

	public function testCorrectArrayInstantiation() {
		var msg = checkMessage(ArrayInstantiationTests.TEST2, new ArrayInstantiationCheck());
		assertEquals(msg, '');
	}
}

class ArrayInstantiationTests {
	public static inline var TEST1:String = "
	class Test {
		var _arr:Array<Int> = new Array<Int>();
	}";

	public static inline var TEST2:String = "
	class Test {
		var _arr:Array<Int> = [];
	}";
}