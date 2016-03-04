package checks;

import checkstyle.checks.AccessOrderCheck;

class AccessOrderCheckTest extends CheckTestCase {

	public function testCorrectOrder() {
		var check = new AccessOrderCheck();
		assertMsg(check, AccessOrderTests.TEST1, '');
	}

	public function testWrongOrder() {
		var check = new AccessOrderCheck();
		assertMsg(check, AccessOrderTests.TEST2, 'Invalid access modifier order: test (modifier: OVERRIDE)');
		assertMsg(check, AccessOrderTests.TEST3, 'Invalid access modifier order: test (modifier: STATIC)');
		assertMsg(check, AccessOrderTests.TEST4, 'Invalid access modifier order: test (modifier: MACRO)');
		assertMsg(check, AccessOrderTests.TEST5, 'Invalid access modifier order: test (modifier: PUBLIC_PRIVATE)');
	}

	public function testModifiers() {
		var check = new AccessOrderCheck();
		check.modifiers = ["DYNAMIC", "PUBLIC_PRIVATE", "OVERRIDE", "INLINE", "STATIC", "MACRO"];
		assertMsg(check, AccessOrderTests.TEST1, 'Invalid access modifier order: test6 (modifier: INLINE)');
		assertMsg(check, AccessOrderTests.TEST2, '');
		assertMsg(check, AccessOrderTests.TEST3, '');
		assertMsg(check, AccessOrderTests.TEST4, '');
		assertMsg(check, AccessOrderTests.TEST5, '');
	}

	public function testIgnore() {
		var check = new AccessOrderCheck();
		check.severity = "ignore";
		assertMsg(check, AccessOrderTests.TEST1, '');
	}

}

class AccessOrderTests {
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