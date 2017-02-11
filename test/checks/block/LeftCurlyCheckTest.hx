package checks.block;

import checkstyle.checks.block.LeftCurlyCheck;

class LeftCurlyCheckTest extends CheckTestCase<LeftCurlyCheckTests> {

	static inline var MSG_EOL:String = "Left curly should be at EOL (only line break or comment after curly)";
	static inline var MSG_NL:String = "Left curly should be on new line (only whitespace before curly)";
	static inline var MSG_NL_SPLIT:String = "Left curly should be on new line (previous expression is split over multiple lines)";
	static inline var MSG_NLOW:String = "Left curly should be at EOL (previous expression is not split over multiple lines)";

	public function testCorrectBraces() {
		var check = new LeftCurlyCheck();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST6);
		assertNoMsg(check, TEST8);
		assertNoMsg(check, TEST9);
		assertNoMsg(check, TEST14);
		assertNoMsg(check, EOL_CASEBLOCK);
		assertNoMsg(check, MACRO_REIFICATION);
		assertNoMsg(check, ISSUE_97);
		assertNoMsg(check, ARRAY_COMPREHENSION_ISSUE_114);
		assertNoMsg(check, ARRAY_COMPREHENSION_2_ISSUE_114);
		assertNoMsg(check, ABSTRACT);
	}

	public function testWrongBraces() {
		var check = new LeftCurlyCheck();
		assertMsg(check, TEST1, MSG_EOL);
		assertMsg(check, TEST2, MSG_EOL);
		assertMsg(check, TEST3, MSG_EOL);
		assertMsg(check, TEST3, MSG_EOL);
		assertMsg(check, TEST5, MSG_EOL);
		assertMsg(check, TEST7, MSG_EOL);
		assertMsg(check, TEST10, MSG_EOL);
		assertMsg(check, NL_CASEBLOCK, MSG_EOL);
		assertMsg(check, NLOW_CASEBLOCK, MSG_EOL);
	}

	public function testBraceOnNL() {
		var check = new LeftCurlyCheck();
		check.option = NL;

		assertMsg(check, TEST, MSG_NL);
		assertNoMsg(check, TEST13);

		check.tokens = [OBJECT_DECL];
		assertMsg(check, TEST4, MSG_NL);
		assertMsg(check, TEST14, MSG_NL);

		check.tokens = [IF];
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST13);

		check.tokens = [FOR];
		assertNoMsg(check, TEST5);
		assertNoMsg(check, TEST13);

		check.tokens = [FUNCTION];
		assertNoMsg(check, TEST13);
	}

	public function testSwitch() {
		var check = new LeftCurlyCheck();
		check.option = NL;
		assertNoMsg(check, TEST15);
		assertNoMsg(check, NL_CASEBLOCK);
		assertMsg(check, EOL_CASEBLOCK, MSG_NL);
		assertMsg(check, NLOW_CASEBLOCK, MSG_NL);
	}

	public function testNLOW() {
		var check = new LeftCurlyCheck();
		check.option = NLOW;
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST12);
		assertNoMsg(check, TEST16);
		assertNoMsg(check, NLOW_CASEBLOCK);
		assertMsg(check, TEST17, MSG_NLOW);
		assertMsg(check, TEST18, MSG_NL_SPLIT);
		assertMsg(check, TEST19, MSG_NL_SPLIT);
	}

	public function testReification() {
		var check = new LeftCurlyCheck();
		check.tokens = [REIFICATION];
		assertMsg(check, MACRO_REIFICATION, MSG_EOL);
	}

	public function testIgnoreEmptySingleline() {
		var check = new LeftCurlyCheck();
		check.ignoreEmptySingleline = false;
		assertMsg(check, NO_FIELDS_CLASS, MSG_EOL);
		assertMsg(check, NO_FIELDS_MACRO, MSG_EOL);

		check.ignoreEmptySingleline = true;
		assertNoMsg(check, NO_FIELDS_CLASS);
		assertNoMsg(check, NO_FIELDS_MACRO);
		assertNoMsg(check, SINGLELINE_ISSUE_153);
	}

	public function testArrayComprehension() {
		var check = new LeftCurlyCheck();
		check.tokens = [ARRAY_COMPREHENSION];
		assertNoMsg(check, ARRAY_COMPREHENSION_2_ISSUE_114);
		assertMsg(check, ARRAY_COMPREHENSION_ISSUE_114, MSG_EOL);

		check.option = NLOW;
		assertNoMsg(check, ARRAY_COMPREHENSION_2_ISSUE_114);
		assertNoMsg(check, ARRAY_COMPREHENSION_NLOW_ISSUE_114);
		assertMsg(check, ARRAY_COMPREHENSION_ISSUE_114, MSG_NL);

		check.option = NL;
		assertMsg(check, ARRAY_COMPREHENSION_2_ISSUE_114, MSG_NL);
		assertMsg(check, ARRAY_COMPREHENSION_ISSUE_114, MSG_NL);
	}
}

@:enum
abstract LeftCurlyCheckTests(String) to String {
	var TEST = "
	class Test {
		function test() {
			if (true) {
				return;
			}

			if (true) return;
			else {
				return;
			}

			if (true) { // comment
				return;
			}
			else if (false) { /* comment */
				return;
			}

			for (i in 0...10) {
				return i;
			}

			while (true) {
				return;
			}
		}
		@SuppressWarnings('checkstyle:LeftCurly')
		function test1()
		{
			if (true)
			{
				return;
			}

			for (i in 0...10)
			{
				return i;
			}

			while (true)
			{
				return;
			}
		}
	}";

	var TEST1 = "
	class Test {
		function test() {
			if (true)
			{
				return;
			}
		}
	}";

	var TEST2 = "
	class Test {
		function test() {
			if (true)
			{ // comment
				return;
			}
			else
				return;
		}
	}";

	var TEST3 = "
	class Test {
		function test()
		{
			if (true) {
				return;
			}
			else {
				return;
			}
		}
	}";

	var TEST4 = "
	class Test {
		function test() {
			if (true) return { x:1,
				y:2,
				z:3 };
		}
	}";

	var TEST5 = "
	class Test {
		function test() {
			for (i in 0...10)
			{
				return i;
			}
		}
	}";

	var TEST6 = "
	class Test {
		function test() {
			for (i in 0...10) if (i < 5) {
				return i;
			}
		}
	}";

	var TEST7 = "
	class Test {
		function test() {
			while (true) { return i; }
		}
	}";

	var TEST8 = "
	class Test {
		function test() {
			while (true) {
				return i;
			}
		}
	}";

	var TEST9 = "
	class Test {
		function test() {
			for (i in 0....10) return i;
		}
	}";

	var TEST10 = "
	class Test
	{
		function test() {
			if (true) return;
		}
	}";

	var TEST12 = "
	class Test {
		function test() {
			var struct = {x:10, y:10, z:20};
		}
	}";

	var TEST13 = "
	class Test
	{
		function test()
		{
			if (true)
			{ // comment
				return;
			}
			else
			{
				if (false)
				{
					return;
				}
			}
		}
	}";

	var TEST14 = "
	typedef Test = {
		x:Int,
		y:Int,
		z:Int,
		point:{x:Int, y:Int, z:Int}
	}";

	var TEST15 = "
	class Test
	{
		public function test(val:Bool):String
		{
			switch(val)
			{
				case true: // do nothing
				default:
					return 'test abc ${val}';
			}
		}
	}";

	var TEST16 = "
	class Test {
		public function test(val:Int,
				val2:Int):String
		{
			switch(val * 10 -
					val / 10)
			{
				case 0: // do nothing
				default:
			}
		}
	}";

	var TEST17 = "
	class Test {
		public function test(val:Int, val2:Int):String
		{
			switch(val * 10 - val / 10)
			{
				case 1: // do nothing
				default:
			}
		}
	}";

	var TEST18 = "
	class Test {
		public function test(val:Int,
				val2:Int):String {
			switch(val * 10 -
					val / 10)
			{
				case 0: // do nothing
				default:
			}
		}
	}";

	var TEST19 = "
	class Test {
		public function test(val:Int,
				val2:Int):String
		{
			switch(val * 10 -
					val / 10) {
				case 0: // do nothing
				default:
			}
		}
	}";

	var NL_CASEBLOCK = "
	class Test
	{
		public function test(val:Int,
				val2:Int):String
		{
			switch(val)
			{
				case 0:
				{
					// do nothing
				}
				default:
			}
		}
	}";

	var EOL_CASEBLOCK = "
	class Test {
		public function test(val:Int,
				val2:Int):String {
			switch(val) {
				case 0: {
					// do nothing
				}
				default:
			}
		}
	}";

	var NLOW_CASEBLOCK = "
	class Test {
		public function test(val:Int,
				val2:Int):String
		{
			switch(val) {
				case (true ||
					!false):
				{
					// do nothing
				}
				default:
			}
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

	var NO_FIELDS_CLASS = "
	class Test {}
	";

	var NO_FIELDS_MACRO = "
	class Test {
		var definition = macro class Font extends flash.text.Font {};
	}";

	var ISSUE_97 = "
	class Test {
		function foo() {
			switch (expr) {
				case xxx: {
						trace ('hello');
					}
				case { expr: EObjectDecl(fields) }:
					for (field in fields) {
						if (field.field == 'priority') {
							switch (field.expr) {
								case { expr: EConst(CInt(value)) }: return Std.parseInt(value);
								case (_): {
									return true;
								}
								default:
									trace ('hello 2');
							}
						}
					}
				default: {
					trace ('hello 2');
				}
			}
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

	var ARRAY_COMPREHENSION_NLOW_ISSUE_114 = "
	class Test {
		public function foo() {
			[for (x in 0...10)
				for
					(y in 0...10)
				{
					x:x,
					y:y
				}];
		}
	}";

	var SINGLELINE_ISSUE_153 = "
	class Test<T:String, A> {
		var positionMap = new Map<Int, {x:Bool, y:Bool}>();
		function foo():Void {}
	}

	class Empty {}";

	var ABSTRACT = "
	abstract MyAbstract(Int) from Int to Int {
	  inline function new(i:Int) {
		this = i;
	  }
	}";
}