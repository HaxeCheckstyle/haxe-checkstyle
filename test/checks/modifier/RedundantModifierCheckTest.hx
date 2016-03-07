package checks.modifier;

import checkstyle.checks.modifier.RedundantModifierCheck;

class RedundantModifierCheckTest extends CheckTestCase {

	public function testCorrectUsage() {
		assertNoMsg(new RedundantModifierCheck(), RedundantModifierTests.TEST);
		assertNoMsg(new RedundantModifierCheck(), RedundantModifierTests.TEST3);
	}

	public function testNormalClass() {
		assertMsg(new RedundantModifierCheck(), RedundantModifierTests.TEST1, 'No need of private keyword: a');
	}

	public function testInterface() {
		assertMsg(new RedundantModifierCheck(), RedundantModifierTests.TEST2, 'No need of public keyword: a');
	}

	public function testClassWithEnforce() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertNoMsg(check, RedundantModifierTests.TEST1);
	}

	public function testClassWithEnforceMissing() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, RedundantModifierTests.TEST, 'Missing private keyword: _onUpdate');
	}

	public function testInterfaceWithEnforce() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertNoMsg(check, RedundantModifierTests.TEST2);
	}

	public function testInterfaceWithEnforceMissing() {
		var check = new RedundantModifierCheck();
		check.enforcePublicPrivate = true;
		assertMsg(check, RedundantModifierTests.TEST3, 'Missing public keyword: a');
	}

	public function testClassWithPublicFields() {
		var check = new RedundantModifierCheck();
		assertNoMsg(check, RedundantModifierTests.TEST4);
		assertMsg(check, RedundantModifierTests.TEST5, 'No need of public keyword: foo');

		check.enforcePublicPrivate = true;
		assertMsg(check, RedundantModifierTests.TEST6, 'Missing public keyword: foo');
	}

	public function testEnumAbstract() {
		var check = new RedundantModifierCheck();
		assertMsg(check, RedundantModifierTests.TEST7, 'No need of public keyword: value');
		assertNoMsg(check, RedundantModifierTests.TEST8);
		assertMsg(check, RedundantModifierTests.TEST9, 'No need of private keyword: CONSTANT');
		assertNoMsg(check, RedundantModifierTests.TEST10);
		assertMsg(check, RedundantModifierTests.TEST11, 'No need of private keyword: foo');
		assertNoMsg(check, RedundantModifierTests.TEST12);

		check.enforcePublicPrivate = true;
		assertNoMsg(check, RedundantModifierTests.TEST7);
		assertMsg(check, RedundantModifierTests.TEST8, 'Missing public keyword: value');
		assertNoMsg(check, RedundantModifierTests.TEST9);
		assertMsg(check, RedundantModifierTests.TEST10, 'Missing private keyword: CONSTANT');
		assertNoMsg(check, RedundantModifierTests.TEST11);
		assertMsg(check, RedundantModifierTests.TEST12, 'Missing private keyword: foo');
	}

	public function testConstructor() {
		var check = new RedundantModifierCheck();
		assertNoMsg(check, RedundantModifierTests.TEST13);
		assertMsg(check, RedundantModifierTests.TEST14, 'No need of private keyword: new');
		assertNoMsg(check, RedundantModifierTests.TEST15);

		check.enforcePublicPrivate = true;
		assertMsg(check, RedundantModifierTests.TEST13, 'Missing private keyword: new');
		assertNoMsg(check, RedundantModifierTests.TEST14);
		assertNoMsg(check, RedundantModifierTests.TEST15);
	}
}

class RedundantModifierTests {
	public static inline var TEST:String = "
	abstractAndClass Test {
		var a:Int;

		function _onUpdate() {}

		public function test(){}
	}";

	public static inline var TEST1:String = "
	abstractAndClass Test {
		private var a:Int;
	}";

	public static inline var TEST2:String = "
	interface Test {
		public var a:Int;
	}";

	public static inline var TEST3:String = "
	interface Test {
		var a:Int;
	}";

	public static inline var TEST4:String = "
	@:publicFields
	class Test {
		private function foo() {}
	}";

	public static inline var TEST5:String = "
	@:publicFields
	class Test {
		public function foo() {}
	}";

	public static inline var TEST6:String = "
	@:publicFields
	class Test {
		function foo() {}
	}";

	public static inline var TEST7:String = "
	@:enum
	abstract Test(Int) {
		public var value = 0;
	}";

	public static inline var TEST8:String = "
	@:enum
	abstract Test(Int) {
		var value = 0;
	}";

	public static inline var TEST9:String = "
	@:enum
	abstract Test(Int) {
		private static inline var CONSTANT = 0;
	}";

	public static inline var TEST10:String = "
	@:enum
	abstract Test(Int) {
		static inline var CONSTANT = 0;
	}";

	public static inline var TEST11:String = "
	@:enum
	abstract Test(Int) {
		private function foo() {}
	}";

	public static inline var TEST12:String = "
	@:enum
	abstract Test(Int) {
		function foo() {}
	}";

	public static inline var TEST13:String = "
	abstractAndClass Test {
		function new() {}
	}";

	public static inline var TEST14:String = "
	abstractAndClass Test {
		private function new() {}
	}";

	public static inline var TEST15:String = "
	abstractAndClass Test {
		public function new() {}
	}";
}