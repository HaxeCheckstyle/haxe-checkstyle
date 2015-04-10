package ;

import checkstyle.checks.TypeCheck;

class TypeCheckTest extends CheckTestCase {

	public function testClassVar() {
		var msg = checkMessage(TypeTests.TEST1, new TypeCheck());
		assertEquals(msg, 'Missing type: _a');
	}

	public function testStaticClassVar() {
		var msg = checkMessage(TypeTests.TEST2, new TypeCheck());
		assertEquals(msg, 'Missing type: A');
	}
}

class TypeTests {
	public static inline var TEST1:String = "
	class Test {
		var _a;
	}";

	public static inline var TEST2:String = "
	class Test {
		static inline var A = 1;
	}";
}