package checks.type;

import checkstyle.checks.type.TypeCheck;

class TypeCheckTest extends CheckTestCase {

	public function testClassVar() {
		assertMsg(new TypeCheck(), TypeTests.TEST1, 'Type not specified: _a');
	}

	public function testStaticClassVar() {
		assertMsg(new TypeCheck(), TypeTests.TEST2, 'Type not specified: A');
	}
	
	public function testEnumAbstract() {
		assertMsg(new TypeCheck(), TypeTests.TEST3, '');
		assertMsg(new TypeCheck(), TypeTests.TEST4, 'Type not specified: VALUE');

		var check = new TypeCheck();
		check.ignoreEnumAbstractValues = false;
		assertMsg(check, TypeTests.TEST3, 'Type not specified: VALUE');
	}
}

class TypeTests {
	public static inline var TEST1:String = "
	class Test {
		var _a;

		@SuppressWarnings('checkstyle:Type')
		var _b;
	}";

	public static inline var TEST2:String = "
	class Test {
		static inline var A = 1;
	}";

	public static inline var TEST3:String =
	"@:enum
	abstract Test(Int) {
		var VALUE = 0;
	}";

	public static inline var TEST4:String =
	"@:enum
	abstract Test(Int) {
		static inline var VALUE = 0;
	}";
}