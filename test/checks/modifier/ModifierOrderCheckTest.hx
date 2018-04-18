package checks.modifier;

import checkstyle.checks.modifier.ModifierOrderCheck;

class ModifierOrderCheckTest extends CheckTestCase<ModifierOrderCheckTests> {

	static inline var ERROR:String = '"test" modifier order is invalid (modifier: "PUBLIC_PRIVATE")';

	@Test
	public function testCorrectOrder() {
		var check = new ModifierOrderCheck();
		assertNoMsg(check, TEST1);
	}

	@Test
	public function testWrongOrder() {
		var check = new ModifierOrderCheck();
		assertMsg(check, TEST2, '"test" modifier order is invalid (modifier: "OVERRIDE")');
		assertMsg(check, TEST3, '"test" modifier order is invalid (modifier: "STATIC")');
		assertMsg(check, TEST4, '"test" modifier order is invalid (modifier: "MACRO")');
		assertMsg(check, TEST5, ERROR);
		assertMsg(check, TEST7, ERROR);
		assertMsg(check, TEST8, ERROR);
	}

	@Test
	public function testModifiers() {
		var check = new ModifierOrderCheck();
		check.modifiers = [DYNAMIC, PUBLIC_PRIVATE, OVERRIDE, INLINE, STATIC, MACRO];
		assertMsg(check, TEST1, '"test6" modifier order is invalid (modifier: "INLINE")');
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, TEST6);
	}

	@Test
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

	var TEST6 =
	"interface Test {
		dynamic public function test();
	}";

	var TEST7 =
	"abstractAndClass Test {
		inline public var test:String=0;
	}";

	var TEST8 =
	"abstractAndClass Test {
		inline public var test(default,null):String=0;
	}";
}
