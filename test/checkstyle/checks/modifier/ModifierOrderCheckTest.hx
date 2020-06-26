package checkstyle.checks.modifier;

class ModifierOrderCheckTest extends CheckTestCase<ModifierOrderCheckTests> {
	@Test
	public function testCorrectOrder() {
		var check = new ModifierOrderCheck();
		assertNoMsg(check, TEST1);
		#if haxe4
		assertNoMsg(check, TEST_FINAL);
		#end
	}

	@Test
	public function testWrongOrder() {
		var check = new ModifierOrderCheck();
		assertMsg(check, TEST2, 'modifier order for field "test" is "public override" but should be "override public"');
		assertMsg(check, TEST3, 'modifier order for field "test" is "public inline static" but should be "public static inline"');
		assertMsg(check, TEST4, 'modifier order for field "test" is "public macro" but should be "macro public"');
		assertMsg(check, TEST5, 'modifier order for field "test" is "dynamic public" but should be "public dynamic"');
		assertMsg(check, TEST7, 'modifier order for field "test" is "inline public" but should be "public inline"');
		assertMsg(check, TEST8, 'modifier order for field "test" is "inline public" but should be "public inline"');
	}

	@Test
	public function testModifiers() {
		var check = new ModifierOrderCheck();
		check.modifiers = [DYNAMIC, PUBLIC_PRIVATE, OVERRIDE, INLINE, STATIC, MACRO];
		assertMessages(check, TEST1, [
			'modifier order for field "test1" is "override public" but should be "public override"',
			'modifier order for field "test2" is "override private" but should be "private override"',
			'modifier order for field "test6" is "public static inline" but should be "public inline static"'
		]);
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
	var TEST2 = "
	abstractAndClass Test {
		public override function test() {}
	}";
	var TEST3 = "
	abstractAndClass Test {
		public inline static function test() {}
	}";
	var TEST4 = "
	abstractAndClass Test {
		public macro function test() {}
	}";
	var TEST5 = "
	abstractAndClass Test {
		dynamic public function test() {}
	}";
	var TEST6 = "
	interface Test {
		dynamic public function test();
	}";
	var TEST7 = "
	abstractAndClass Test {
		inline public var test:String=0;
	}";
	var TEST8 = "
	abstractAndClass Test {
		inline public var test(default,null):String=0;
	}";
	var TEST_FINAL = "
	abstractAndClass Test {
		public inline final test:String=0;
	}";
}