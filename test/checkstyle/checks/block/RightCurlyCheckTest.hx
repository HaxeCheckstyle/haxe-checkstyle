package checkstyle.checks.block;

class RightCurlyCheckTest extends CheckTestCase<RightCurlyCheckTests> {
	static inline var MSG_ALONE:String = "Right curly should be alone on a new line";
	static inline var MSG_NOT_SAME_LINE:String = "Right curly should not be on same line as left curly";
	static inline var MSG_SAME_LINE:String = 'Right curly should be on same line as following block (e.g. "} else" or "} catch")';

	@Test
	public function testCorrectAloneOrSingleLine() {
		var check = new RightCurlyCheck();
		assertNoMsg(check, ALONE_OR_SINGLELINE_CORRECT);

		assertNoMsg(check, SINGLELINE_IF);
		assertNoMsg(check, SINGLELINE_FUNCTION);
		assertNoMsg(check, SINGLELINE_FOR);
		assertNoMsg(check, SINGLELINE_WHILE);
		assertNoMsg(check, SINGLELINE_TRY_CATCH);
		assertNoMsg(check, SINGLELINE_INTERFACE);
		assertNoMsg(check, SINGLELINE_CLASS);
		assertNoMsg(check, SINGLELINE_TYPEDEF);
		assertNoMsg(check, SINGLELINE_SWITCH);
		assertNoMsg(check, SINGLELINE_CASE);
		assertNoMsg(check, SINGLELINE_OBJECT);
		assertNoMsg(check, SINGLELINE_ABSTRACT);
		assertNoMsg(check, SINGLELINE_ENUM);
		assertNoMsg(check, SINGLELINE_NESTED_OBJECT);

		assertNoMsg(check, MACRO_REIFICATION);

		assertNoMsg(check, ALONE_IF);
		assertNoMsg(check, ALONE_FUNCTION);
		assertNoMsg(check, ALONE_FOR);
		assertNoMsg(check, ALONE_WHILE);
		assertNoMsg(check, ALONE_TRY_CATCH);
		assertNoMsg(check, ALONE_INTERFACE);
		assertNoMsg(check, ALONE_CLASS);
		assertNoMsg(check, ALONE_TYPEDEF);
		assertNoMsg(check, ALONE_SWITCH);
		assertNoMsg(check, ALONE_CASE);
		assertNoMsg(check, ALONE_OBJECT);
		assertNoMsg(check, ALONE_ABSTRACT);
		assertNoMsg(check, ALONE_ENUM);
		assertNoMsg(check, ALONE_NESTED_OBJECT);

		assertNoMsg(check, ARRAY_COMPREHENSION_ISSUE_114);
		assertNoMsg(check, ARRAY_COMPREHENSION_2_ISSUE_114);

		assertNoMsg(check, CONSTRUCTOR_OBJECT_DECL_ISSUE_152);
	}

	@Test
	public function testIncorrectAloneOrSingleLine() {
		var check = new RightCurlyCheck();
		assertMsg(check, SAMELINE_IF, MSG_ALONE);
		assertMsg(check, SAMELINE_TRY_CATCH, MSG_ALONE);
		assertMsg(check, SAMELINE_NESTED_OBJECT, MSG_ALONE);
	}

	@Test
	public function testCorrectSame() {
		var check = new RightCurlyCheck();
		check.option = SAME;
		assertNoMsg(check, SAMELINE_IF);
		assertNoMsg(check, SAMELINE_TRY_CATCH);
		assertNoMsg(check, SAMELINE_NESTED_OBJECT);

		assertNoMsg(check, ALONE_FUNCTION);
		assertNoMsg(check, ALONE_FOR);
		assertNoMsg(check, ALONE_WHILE);
		assertNoMsg(check, ALONE_INTERFACE);
		assertNoMsg(check, ALONE_CLASS);
		assertNoMsg(check, ALONE_TYPEDEF);
		assertNoMsg(check, ALONE_SWITCH);
		assertNoMsg(check, ALONE_CASE);
		assertNoMsg(check, ALONE_OBJECT);
		assertNoMsg(check, ALONE_ABSTRACT);
		assertNoMsg(check, ALONE_ENUM);
		assertNoMsg(check, ALONE_NESTED_OBJECT);

		assertNoMsg(check, MACRO_REIFICATION);
	}

	@Test
	public function testIncorrectSame() {
		var check = new RightCurlyCheck();
		check.option = SAME;
		assertMsg(check, SINGLELINE_IF, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_FOR, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_WHILE, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_TRY_CATCH, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_INTERFACE, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_CLASS, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_TYPEDEF, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_SWITCH, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_CASE, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_OBJECT, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_ABSTRACT, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_ENUM, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_NESTED_OBJECT, MSG_NOT_SAME_LINE);

		assertMsg(check, ALONE_IF, MSG_SAME_LINE);
		assertMsg(check, ALONE_TRY_CATCH, MSG_SAME_LINE);
	}

	@Test
	public function testCorrectAlone() {
		var check = new RightCurlyCheck();
		check.option = ALONE;
		assertNoMsg(check, ALONE_IF);
		assertNoMsg(check, ALONE_FOR);
		assertNoMsg(check, ALONE_WHILE);
		assertNoMsg(check, ALONE_FUNCTION);
		assertNoMsg(check, ALONE_INTERFACE);
		assertNoMsg(check, ALONE_CLASS);
		assertNoMsg(check, ALONE_TYPEDEF);
		assertNoMsg(check, ALONE_SWITCH);
		assertNoMsg(check, ALONE_CASE);
		assertNoMsg(check, ALONE_OBJECT);
		assertNoMsg(check, ALONE_ABSTRACT);
		assertNoMsg(check, ALONE_ENUM);
		assertNoMsg(check, ALONE_NESTED_OBJECT);

		assertNoMsg(check, MACRO_REIFICATION);
	}

	@Test
	public function testIncorrectAlone() {
		var check = new RightCurlyCheck();
		check.option = ALONE;
		assertMsg(check, SINGLELINE_IF, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_FUNCTION, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_FOR, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_WHILE, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_TRY_CATCH, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_INTERFACE, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_CLASS, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_TYPEDEF, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_SWITCH, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_CASE, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_OBJECT, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_ABSTRACT, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_ENUM, MSG_NOT_SAME_LINE);
		assertMsg(check, SINGLELINE_NESTED_OBJECT, MSG_NOT_SAME_LINE);

		assertMsg(check, SAMELINE_IF, MSG_ALONE);
		assertMsg(check, SAMELINE_TRY_CATCH, MSG_ALONE);
		assertMsg(check, SAMELINE_NESTED_OBJECT, MSG_ALONE);
	}

	@Test
	public function testTokenIF() {
		var check = new RightCurlyCheck();
		check.tokens = [IF];
		assertNoMsg(check, SINGLELINE_IF);
		assertNoMsg(check, SINGLELINE_FOR);
		assertMsg(check, SAMELINE_IF, MSG_ALONE);
		assertNoMsg(check, SAMELINE_TRY_CATCH);
		assertNoMsg(check, ALONE_IF);
		assertNoMsg(check, ALONE_FOR);

		check.option = SAME;
		assertMsg(check, SINGLELINE_IF, MSG_NOT_SAME_LINE);
		assertNoMsg(check, SINGLELINE_FOR);
		assertNoMsg(check, SAMELINE_IF);
		assertNoMsg(check, SAMELINE_TRY_CATCH);
		assertMsg(check, ALONE_IF, MSG_SAME_LINE);
		assertNoMsg(check, ALONE_FOR);

		check.option = ALONE;
		assertMsg(check, SINGLELINE_IF, MSG_NOT_SAME_LINE);
		assertNoMsg(check, SINGLELINE_FOR);
		assertMsg(check, SAMELINE_IF, MSG_ALONE);
		assertNoMsg(check, SAMELINE_TRY_CATCH);
		assertNoMsg(check, ALONE_IF);
		assertNoMsg(check, ALONE_FOR);
	}

	@Test
	public function testTokenMacroReification() {
		var check = new RightCurlyCheck();
		check.tokens = [REIFICATION];
		assertNoMsg(check, MACRO_REIFICATION);

		check.option = SAME;
		assertMsg(check, MACRO_REIFICATION, MSG_NOT_SAME_LINE);

		check.option = ALONE;
		assertMsg(check, MACRO_REIFICATION, MSG_NOT_SAME_LINE);
	}

	@Test
	public function testArrayComprehension() {
		var check = new RightCurlyCheck();
		check.tokens = [ARRAY_COMPREHENSION];
		assertNoMsg(check, ARRAY_COMPREHENSION_ISSUE_114);
		assertNoMsg(check, ARRAY_COMPREHENSION_2_ISSUE_114);

		check.option = SAME;
		assertMsg(check, ARRAY_COMPREHENSION_ISSUE_114, MSG_NOT_SAME_LINE);
		assertNoMsg(check, ARRAY_COMPREHENSION_2_ISSUE_114);

		check.option = ALONE;
		assertMsg(check, ARRAY_COMPREHENSION_ISSUE_114, MSG_NOT_SAME_LINE);
		assertNoMsg(check, ARRAY_COMPREHENSION_2_ISSUE_114);
	}
}

@:enum
abstract RightCurlyCheckTests(String) to String {
	var ALONE_OR_SINGLELINE_CORRECT = "
	class Test {
		function test() {
			if (true) { return; }

			if (true) return;
			else {
				return;
			}

			if (true) { return; } else { trace ('test'); }

			if (true) { // comment
				return;
			}
			else if (false) {
				return;
			}

			for (i in 0...10) {
				return i;
			}

			for (i in 0...10) { return i; }

			while (true) {
				return;
			}

			var x = { x: 100, y: 100 };
			var x = { x: 100, y: 100
			};

			while (true) { return; }
		}
		@SuppressWarnings('checkstyle:RightCurly')
		function test1()
		{
			if (true)
			{
				return;
			} else trace ('test1');

			for (i in 0...10)
			{ return i; }

			while (true)
			{ return; }
		}
	}";
	var SINGLELINE_IF = "
	class Test {
		function test() {
			if (true) { return; } else { return; }
		}
	}";
	var SAMELINE_IF = "
	class Test {
		function test() {
			if (true) {
				return;
			} else {
				return;
			}
		}
	}";
	var ALONE_IF = "
	class Test {
		function test() {
			if (true) {
				return;
			}
			else {
				return;
			}
		}
	}";
	var SINGLELINE_FUNCTION = "
	class Test {
		function test() { trace ('test'); }
	}";
	var ALONE_FUNCTION = "
	class Test {
		function test() {
			trace ('test');
		}
	}";
	var SINGLELINE_FOR = "
	class Test {
		function test() {
			for (i in 0...100) { trace ('$i'); }
		}
	}";
	var ALONE_FOR = "
	class Test {
		function test() {
			for (i in 0...100) {
				trace ('$i');
			}
		}
	}";
	var SINGLELINE_WHILE = "
	class Test {
		function test() {
			while (true) { trace ('test'); }
		}
	}";
	var ALONE_WHILE = "
	class Test {
		function test() {
			while (true) {
				trace ('test');
			}
		}
	}";
	var SINGLELINE_TRY_CATCH = "
	class Test {
		function test() {
			try { trace ('test'); } catch (e:Dynamic) {}
		}
	}";
	var SAMELINE_TRY_CATCH = "
	class Test {
		function test() {
			try {
				trace ('test');
			} catch (e:Dynamic) {
			}
		}
	}";
	var ALONE_TRY_CATCH = "
	class Test {
		function test() {
			try {
				trace ('test');
			}
			catch (e:Dynamic) {
			}
		}
	}";
	var SINGLELINE_INTERFACE = "
	interface Test { function test(); }";
	var ALONE_INTERFACE = "
	interface Test {
		function test();
	}";
	var SINGLELINE_CLASS = "
	class Test { function test() {}; }";
	var ALONE_CLASS = "
	class Test {
		function test() {
		};
	}";
	var SINGLELINE_TYPEDEF = "
	typedef Test = { x:Int, y:Int, z:Int }";
	var ALONE_TYPEDEF = "
	typedef Test = {
		x:Int,
		y:Int,
		z:Int
	}";
	var SINGLELINE_SWITCH = "
	class Test {
		function test(val:Bool) {
			switch (val) { case true: return; default: trace(val); }
		}
	}";
	var ALONE_SWITCH = "
	class Test {
		function test() {
			switch (val) {
				case true:
					return;
				default:
					trace(val);
			}
		}
	}";
	var SINGLELINE_CASE = "
	class Test {
		function test(val:Bool) {
			switch (val) {
				case true: return;
				case false: { trace(val); return; }
				default: { trace('unreachable'); return; }
			}
		}
	}";
	var ALONE_CASE = "
	class Test {
		function test() {
			switch (val) {
				case true: return;
				case false: {
					trace(val);
					return;
				}
				default: {
					trace('unreachable');
					return;
				}
			}
		}
	}";
	var SINGLELINE_OBJECT = "
	class Test {
		function test(val:Bool) {
			var p = { x:100, y: 10, z: 2 };
		}
	}";
	var ALONE_OBJECT = "
	class Test {
		function test() {
			var p = {
				x:100,
				y: 10,
				z: 2
			};
		}
	}";
	var SINGLELINE_ABSTRACT = "
	abstract Test(String) { @:from public static function fromString(value:String) { return new Test('Hello $value'); } }";
	var ALONE_ABSTRACT = "
	abstract Test(String) {
		@:from
		public static function fromString(value:String) {
			return new Test('Hello $value');
		}
	}";
	var SINGLELINE_ENUM = "
	enum Test { Monday; Tuesday; Wednesday; Thursday; Friday; Weekend(day:String); }";
	var ALONE_ENUM = "
	enum Test {
		Monday;
		Tuesday;
		Wednesday;
		Thursday;
		Friday;
		Weekend(day:String);
	}";
	var SINGLELINE_NESTED_OBJECT = "
	class Test {
		public function test() {
			var l = {
				p1 : { x:100, y: -x, z: 2 },
				p2 : { x:200, y: 50, z: 2 }
			};
			var l2 = [
				{ x:100, y: 10, z: [2, b] },
				{ x:200, y: 50, z: 2 }];
		}
	}";
	var SAMELINE_NESTED_OBJECT = "
	class Test {
		public function test() {
			var l = {
				p1 : {
					x:100,
					y: 10,
					z: 2
				},
				p2 : {
					x:200,
					y: 50,
					z: -y
				}};
			var l2 = [
				{
					x:100,
					y: -x,
					z: 2
				},
				{
					x:200,
					y: 50,
					z: 2
				}];
		}
	}";
	var ALONE_NESTED_OBJECT = "
	class Test {
		public function test() {
			var l = {
				p1 : {
					x:100,
					y: 10,
					z: 2
				},
				p2 : {
					x:200,
					y: -x,
					z: 2
				}
			};
			var l2 = [
				{
					x:100,
					y: -z,
					z: 2
				},
				{
					x:200,
					y: 50,
					z: 2
				}
			];
		}
	}";
	var MACRO_REIFICATION = "
	class Test {
		public function test(val:Int) {
			var str = 'Hello, world';
			var expr = macro for (i in 0...10) trace($v{str});
			var e = macro ${str}.toLowerCase();
		}
	}";
	var ARRAY_COMPREHENSION_ISSUE_114 = "
	class Test {
		public function foo() {
			[for (i in 0...10) {index:i}];
			[for (x in 0...10) for (y in 0...10) {x:x, y:y}];
		}
	}";
	var ARRAY_COMPREHENSION_2_ISSUE_114 = "
	class Test {
		public function foo() {
			[for (i in 0...10) {
				index:i
			}];
			[for (x in 0...10)
				for (y in 0...10) {
					x:x,
					y:y
				}];
		}
	}";
	var CONSTRUCTOR_OBJECT_DECL_ISSUE_152 = "
	class Test {
		var field = new Object({x:0});
	}";
}