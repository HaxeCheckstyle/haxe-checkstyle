package checkstyle.checks.type;

class TypeCheckTest extends CheckTestCase<TypeCheckTests> {
	@Test
	public function testClassVar() {
		assertMsg(new TypeCheck(), TEST1, 'Variable "_a" type not specified');
	}

	@Test
	public function testStaticClassVar() {
		assertMsg(new TypeCheck(), TEST2, 'Variable "A" type not specified');
	}

	@Test
	public function testEnumAbstract() {
		assertNoMsg(new TypeCheck(), TEST3);
		assertMsg(new TypeCheck(), TEST4, 'Variable "VALUE" type not specified');

		var check = new TypeCheck();
		check.ignoreEnumAbstractValues = false;
		assertMsg(check, TEST3, 'Variable "VALUE" type not specified');
	}
}

enum abstract TypeCheckTests(String) to String {
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
	var TEST3 = "
	enum
	abstract Test(Int) {
		var VALUE = 0;
	}";
	var TEST4 = "
	enum
	abstract Test(Int) {
		static inline var VALUE = 0;
	}";
}