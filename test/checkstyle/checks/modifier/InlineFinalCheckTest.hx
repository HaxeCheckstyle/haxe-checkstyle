package checkstyle.checks.modifier;

#if haxe_ver4
class InlineFinalCheckTest extends CheckTestCase<InlineFinalCheckTests> {
	static inline var ERROR:String = 'Consider using "inline final" for field "test"';

	@Test
	public function testCorrectOrder() {
		var check = new InlineFinalCheck();
		assertNoMsg(check, TEST_INLINE_FINAL);
	}

	@Test
	public function testWrongOrder() {
		var check = new InlineFinalCheck();
		assertMsg(check, TEST_INLINE_VAR, ERROR);
	}
}
#end

@:enum
abstract InlineFinalCheckTests(String) to String {
	var TEST_INLINE_FINAL = "
	abstractAndClass Test {
		public inline final test:String='0';
		final function test2() {
		}
	}";
	var TEST_INLINE_VAR = "
	abstractAndClass Test {
		inline public var test:String='0';
		inline function test2() {
		}
	}";
}