package checks.modifier;

import checkstyle.checks.modifier.RedundantModifierCheck;

class RedundantModifierCheckTest extends CheckTestCase<RedundantModifierCheckTests> {

	public function testCorrectUsage() {
		assertNoMsg(new RedundantModifierCheck(), TEST);
		assertNoMsg(new RedundantModifierCheck(), TEST3);
	}

	public function testNormalClass() {
		assertMsg(new RedundantModifierCheck(), TEST1, 'No need of "private" keyword: "a"');
	}

	public function testInterface() {
		assertMsg(new RedundantModifierCheck(), TEST2, 'No need of "public" keyword: "a"');
	}

	public function testClassWithEnforce() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertNoMsg(check, TEST1);
	}

	public function testClassWithEnforceMissing() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, TEST, 'Missing "private" keyword: "_onUpdate"');
	}

	public function testInterfaceWithEnforce() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertNoMsg(check, TEST2);
	}

	public function testInterfaceWithEnforceMissing() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, TEST3, 'Missing "public" keyword: "a"');
	}

	public function testClassWithPublicFields() {
		var check = new RedundantModifierCheck();
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'No need of "public" keyword: "foo"');

		check.enforcePublicPrivate = true;
		assertMsg(check, TEST6, 'Missing "public" keyword: "foo"');
	}

	public function testEnumAbstract() {
		var check = new RedundantModifierCheck();
		assertMsg(check, TEST7, 'No need of "public" keyword: "value"');
		assertNoMsg(check, TEST8);
		assertMsg(check, TEST9, 'No need of "private" keyword: "CONSTANT"');
		assertNoMsg(check, TEST10);
		assertMsg(check, TEST11, 'No need of "private" keyword: "foo"');
		assertNoMsg(check, TEST12);

		check.enforcePublicPrivate = true;
		assertNoMsg(check, TEST7);
		assertMsg(check, TEST8, 'Missing "public" keyword: "value"');
		assertNoMsg(check, TEST9);
		assertMsg(check, TEST10, 'Missing "private" keyword: "CONSTANT"');
		assertNoMsg(check, TEST11);
		assertMsg(check, TEST12, 'Missing "private" keyword: "foo"');
	}

	public function testConstructor() {
		var check = new RedundantModifierCheck();
		assertNoMsg(check, TEST13);
		assertMsg(check, TEST14, 'No need of "private" keyword: "new"');
		assertNoMsg(check, TEST15);

		check.enforcePublicPrivate = true;
		assertMsg(check, TEST13, 'Missing "private" keyword: "new"');
		assertNoMsg(check, TEST14);
		assertNoMsg(check, TEST15);
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