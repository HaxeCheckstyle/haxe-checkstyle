package checks.type;

import checkstyle.checks.type.TypeCheck;

class TypeCheckTest extends CheckTestCase<TypeCheckTests> {

	public function testClassVar() {
		assertMsg(new TypeCheck(), TEST1, 'Type not specified: _a');
	}

	public function testStaticClassVar() {
		assertMsg(new TypeCheck(), TEST2, 'Type not specified: A');
	}

	public function testEnumAbstract() {
		assertNoMsg(new TypeCheck(), TEST3);
		assertMsg(new TypeCheck(), TEST4, 'Type not specified: VALUE');

		var check = new TypeCheck();
		check.ignoreEnumAbstractValues = false;
		assertMsg(check, TEST3, 'Type not specified: VALUE');
	}
}

@:enum
abstract TypeCheckTests(String) to String {
	var TEST1 = "
	class Test {
		var _a;

		@SuppressWarnings('checkstyle:Type')
		var _b;
	}";

	var TEST2 = "
	class Test {
		static inline var A = 1;
	}";

	var TEST3 =
	"@:enum
	abstract Test(Int) {
		var VALUE = 0;
	}";

	var TEST4 =
	"@:enum
	abstract Test(Int) {
		static inline var VALUE = 0;
	}";
}