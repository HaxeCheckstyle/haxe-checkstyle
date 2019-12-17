package checkstyle.checks.modifier;

#if haxe4
class FinalCheckTest extends CheckTestCase<FinalCheckTests> {
	static inline var ERROR_INLINE_VAR:String = 'Consider using "inline final" for field "test"';
	static inline var ERROR_PUBLIC_STATIC:String = 'Consider making public static field "test" "final" or "private"';

	@Test
	public function testInlineFinal() {
		var check = new FinalCheck();
		assertNoMsg(check, TEST_INLINE_FINAL);
	}

	@Test
	public function testNoncompliant() {
		var check = new FinalCheck();
		assertMsg(check, TEST_INLINE_VAR, ERROR_INLINE_VAR);
		assertMsg(check, TEST_PUBLIC_STATIC_VAR, ERROR_PUBLIC_STATIC);
	}
}
#end

@:enum
abstract FinalCheckTests(String) to String {
	var TEST_INLINE_FINAL = "
	abstractAndClass Test {
		public inline final test:String = '0';
		public static final test2:String = '0';
		public static var test3(default, null):String = '0';
		private static var test4:String = '0';
		public var test5:String = '0';
		private var test5:String = '0';
		final function test2() {
		}
	}";
	var TEST_INLINE_VAR = "
	abstractAndClass Test {
		inline public var test:String = '0';
		inline function test2() {
		}
	}";
	var TEST_PUBLIC_STATIC_VAR = "
	abstractAndClass Test {
		public static var test:String = '0';
		public static function test2() {
		}
	}";
}