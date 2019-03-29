package checkstyle.checks.modifier;

class RedundantModifierCheckTest extends CheckTestCase<RedundantModifierCheckTests> {
	@Test
	public function testCorrectUsage() {
		assertNoMsg(new RedundantModifierCheck(), TEST);
		assertNoMsg(new RedundantModifierCheck(), TEST3);
	}

	@Test
	public function testNormalClass() {
		assertMsg(new RedundantModifierCheck(), TEST1, '"private" keyword is redundant for "a"');
	}

	@Test
	public function testInterface() {
		assertMsg(new RedundantModifierCheck(), TEST2, '"public" keyword is redundant for "a"');
	}

	@Test
	public function testClassWithEnforce() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertNoMsg(check, TEST1);
	}

	@Test
	public function testClassWithEnforceMissing() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, TEST, 'Missing "private" keyword for "_onUpdate"');
	}

	@Test
	public function testInterfaceWithEnforce() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertNoMsg(check, TEST2);
	}

	@Test
	public function testInterfaceWithEnforceMissing() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, TEST3, 'Missing "public" keyword for "a"');
	}

	@Test
	public function testClassWithPublicFields() {
		var check = new RedundantModifierCheck();
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, '"public" keyword is redundant for "foo"');

		check.enforcePublicPrivate = true;
		assertMsg(check, TEST6, 'Missing "public" keyword for "foo"');
	}

	@Test
	public function testEnumAbstract() {
		var check = new RedundantModifierCheck();
		assertMsg(check, TEST7, '"public" keyword is redundant for "value"');
		assertNoMsg(check, TEST8);
		assertMsg(check, TEST9, '"private" keyword is redundant for "CONSTANT"');
		assertNoMsg(check, TEST10);
		assertMsg(check, TEST11, '"private" keyword is redundant for "foo"');
		assertNoMsg(check, TEST12);

		check.enforcePublicPrivate = true;
		assertNoMsg(check, TEST7);
		assertMsg(check, TEST8, 'Missing "public" keyword for "value"');
		assertNoMsg(check, TEST9);
		assertMsg(check, TEST10, 'Missing "private" keyword for "CONSTANT"');
		assertNoMsg(check, TEST11);
		assertMsg(check, TEST12, 'Missing "private" keyword for "foo"');
	}

	@Test
	public function testConstructor() {
		var check = new RedundantModifierCheck();
		assertNoMsg(check, TEST13);
		assertMsg(check, TEST14, '"private" keyword is redundant for "new"');
		assertNoMsg(check, TEST15);

		check.enforcePublicPrivate = true;
		assertMsg(check, TEST13, 'Missing "private" keyword for "new"');
		assertNoMsg(check, TEST14);
		assertNoMsg(check, TEST15);
	}

	@Test
	public function testJustPublic() {
		var check = new RedundantModifierCheck();
		check.enforcePublic = true;
		assertMsg(check, TEST3, 'Missing "public" keyword for "a"');
		assertMsg(check, TEST1, '"private" keyword is redundant for "a"');
		assertNoMsg(check, TEST4);
	}

	@Test
	public function testJustPrivate() {
		var check = new RedundantModifierCheck();
		check.enforcePrivate = true;
		assertMsg(check, TEST12, 'Missing "private" keyword for "foo"');
		assertMsg(check, TEST2, '"public" keyword is redundant for "a"');
		assertNoMsg(check, TEST3);
	}
}

@:enum
abstract RedundantModifierCheckTests(String) to String {
	var TEST = "
	abstractAndClass Test {
		var a:Int;

		function _onUpdate() {}

		public function test(){}
	}";
	var TEST1 = "
	abstractAndClass Test {
		private var a:Int;
	}";
	var TEST2 = "
	interface Test {
		public var a:Int;
	}";
	var TEST3 = "
	interface Test {
		var a:Int;
	}";
	var TEST4 = "
	@:publicFields
	class Test {
		private function foo() {}
	}";
	var TEST5 = "
	@:publicFields
	class Test {
		public function foo() {}
	}";
	var TEST6 = "
	@:publicFields
	class Test {
		function foo() {}
	}";
	var TEST7 = "
	@:enum
	abstract Test(Int) {
		public var value = 0;
	}";
	var TEST8 = "
	@:enum
	abstract Test(Int) {
		var value = 0;
	}";
	var TEST9 = "
	@:enum
	abstract Test(Int) {
		private static inline var CONSTANT = 0;
	}";
	var TEST10 = "
	@:enum
	abstract Test(Int) {
		static inline var CONSTANT = 0;
	}";
	var TEST11 = "
	@:enum
	abstract Test(Int) {
		private function foo() {}
	}";
	var TEST12 = "
	@:enum
	abstract Test(Int) {
		function foo() {}
	}";
	var TEST13 = "
	abstractAndClass Test {
		function new() {}
	}";
	var TEST14 = "
	abstractAndClass Test {
		private function new() {}
	}";
	var TEST15 = "
	abstractAndClass Test {
		public function new() {}
	}";
}