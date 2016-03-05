package checks;

import checkstyle.checks.ModifierOrderCheck;

class ModifierOrderCheckTest extends CheckTestCase {

	public function testCorrectOrder() {
		var check = new ModifierOrderCheck();
		assertMsg(check, ModifierOrderTests.TEST1, '');
	}

	public function testWrongOrder() {
		var check = new ModifierOrderCheck();
		assertMsg(check, ModifierOrderTests.TEST2, 'Invalid modifier order: test (modifier: OVERRIDE)');
		assertMsg(check, ModifierOrderTests.TEST3, 'Invalid modifier order: test (modifier: STATIC)');
		assertMsg(check, ModifierOrderTests.TEST4, 'Invalid modifier order: test (modifier: MACRO)');
		assertMsg(check, ModifierOrderTests.TEST5, 'Invalid modifier order: test (modifier: PUBLIC_PRIVATE)');
	}

	public function testModifiers() {
		var check = new ModifierOrderCheck();
		check.modifiers = ["DYNAMIC", "PUBLIC_PRIVATE", "OVERRIDE", "INLINE", "STATIC", "MACRO"];
		assertMsg(check, ModifierOrderTests.TEST1, 'Invalid modifier order: test6 (modifier: INLINE)');
		assertMsg(check, ModifierOrderTests.TEST2, '');
		assertMsg(check, ModifierOrderTests.TEST3, '');
		assertMsg(check, ModifierOrderTests.TEST4, '');
		assertMsg(check, ModifierOrderTests.TEST5, '');
	}

	public function testIgnore() {
		var check = new ModifierOrderCheck();
		check.severity = "ignore";
		assertMsg(check, ModifierOrderTests.TEST1, '');
	}

}

class ModifierOrderTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		override public function test1() {}
		override private function test2() {}
		static function test3() {}
		override inline function test4() {}
		macro function test5() {}
		public static inline function test6() {}
	}";

	public static inline var TEST2:String =
	"abstractAndClass Test {
		public override function test() {}
	}";

	public static inline var TEST3:String =
	"abstractAndClass Test {
		public inline static function test() {}
	}";

	public static inline var TEST4:String =
	"abstractAndClass Test {
		public macro function test() {}
	}";

	public static inline var TEST5:String =
	"abstractAndClass Test {
		dynamic public function test() {}
	}";
}