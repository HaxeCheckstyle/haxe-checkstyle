package checks.modifier;

import checkstyle.checks.modifier.ModifierOrderCheck;

class ModifierOrderCheckTest extends CheckTestCase<ModifierOrderCheckTests> {

	public function testCorrectOrder() {
		var check = new ModifierOrderCheck();
		assertNoMsg(check, TEST1);
	}

	public function testWrongOrder() {
		var check = new ModifierOrderCheck();
		assertMsg(check, TEST2, 'Invalid modifier order: test (modifier: OVERRIDE)');
		assertMsg(check, TEST3, 'Invalid modifier order: test (modifier: STATIC)');
		assertMsg(check, TEST4, 'Invalid modifier order: test (modifier: MACRO)');
		assertMsg(check, TEST5, 'Invalid modifier order: test (modifier: PUBLIC_PRIVATE)');
	}

	public function testModifiers() {
		var check = new ModifierOrderCheck();
		check.modifiers = [DYNAMIC, PUBLIC_PRIVATE, OVERRIDE, INLINE, STATIC, MACRO];
		assertMsg(check, TEST1, 'Invalid modifier order: test6 (modifier: INLINE)');
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	public function testIgnore() {
		var check = new ModifierOrderCheck();
		check.severity = "ignore";
		assertNoMsg(check, TEST1);
	}
}

@:enum
abstract ModifierOrderCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		override public function test1() {}
		override private function test2() {}
		static function test3() {}
		override inline function test4() {}
		macro function test5() {}
		public static inline function test6() {}
	}";

	var TEST2 =
	"abstractAndClass Test {
		public override function test() {}
	}";

	var TEST3 =
	"abstractAndClass Test {
		public inline static function test() {}
	}";

	var TEST4 =
	"abstractAndClass Test {
		public macro function test() {}
	}";

	var TEST5 =
	"abstractAndClass Test {
		dynamic public function test() {}
	}";
}