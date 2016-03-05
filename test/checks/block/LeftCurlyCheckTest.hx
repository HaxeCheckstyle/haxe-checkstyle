package checks.block;

import checkstyle.checks.block.LeftCurlyCheck;

class LeftCurlyCheckTest extends CheckTestCase {

	static inline var MSG_EOL:String = 'Left curly should be at EOL (only linebreak or comment after curly)';
	static inline var MSG_NL:String = 'Left curly should be on new line (only whitespace before curly)';
	static inline var MSG_NL_SPLIT:String = 'Left curly should be on new line (previous expression is split over muliple lines)';
	static inline var MSG_NLOW:String = 'Left curly should be at EOL (previous expression is not split over muliple lines)';

	public function testCorrectBraces() {
		var check = new LeftCurlyCheck();
		assertNoMsg(check, LeftCurlyTests.TEST);
		assertNoMsg(check, LeftCurlyTests.TEST4);
		assertNoMsg(check, LeftCurlyTests.TEST6);
		assertNoMsg(check, LeftCurlyTests.TEST8);
		assertNoMsg(check, LeftCurlyTests.TEST9);
		assertNoMsg(check, LeftCurlyTests.TEST14);
		assertNoMsg(check, LeftCurlyTests.EOL_CASEBLOCK);
		assertNoMsg(check, LeftCurlyTests.MACRO_REIFICATION);
		assertNoMsg(check, LeftCurlyTests.ISSUE_97);
	}

	public function testWrongBraces() {
		var check = new LeftCurlyCheck();
		assertMsg(check, LeftCurlyTests.TEST1, MSG_EOL);
		assertMsg(check, LeftCurlyTests.TEST2, MSG_EOL);
		assertMsg(check, LeftCurlyTests.TEST3, MSG_EOL);
		assertMsg(check, LeftCurlyTests.TEST3, MSG_EOL);
		assertMsg(check, LeftCurlyTests.TEST5, MSG_EOL);
		assertMsg(check, LeftCurlyTests.TEST7, MSG_EOL);
		assertMsg(check, LeftCurlyTests.TEST10, MSG_EOL);
		assertMsg(check, LeftCurlyTests.NL_CASEBLOCK, MSG_EOL);
		assertMsg(check, LeftCurlyTests.NLOW_CASEBLOCK, MSG_EOL);
	}

	public function testBraceOnNL() {
		var check = new LeftCurlyCheck();
		check.option = LeftCurlyCheck.NL;

		assertMsg(check, LeftCurlyTests.TEST, MSG_NL);
		assertNoMsg(check, LeftCurlyTests.TEST13);

		check.tokens = [LeftCurlyCheck.OBJECT_DECL];
		assertMsg(check, LeftCurlyTests.TEST4, MSG_NL);
		assertMsg(check, LeftCurlyTests.TEST14, MSG_NL);

		check.tokens = [LeftCurlyCheck.IF];
		assertNoMsg(check, LeftCurlyTests.TEST1);
		assertNoMsg(check, LeftCurlyTests.TEST13);

		check.tokens = [LeftCurlyCheck.FOR];
		assertNoMsg(check, LeftCurlyTests.TEST5);
		assertNoMsg(check, LeftCurlyTests.TEST13);

		check.tokens = [LeftCurlyCheck.FUNCTION];
		assertNoMsg(check, LeftCurlyTests.TEST13);
	}

	public function testSwitch() {
		var check = new LeftCurlyCheck();
		check.option = LeftCurlyCheck.NL;
		assertNoMsg(check, LeftCurlyTests.TEST15);
		assertNoMsg(check, LeftCurlyTests.NL_CASEBLOCK);
		assertMsg(check, LeftCurlyTests.EOL_CASEBLOCK, MSG_NL);
		assertMsg(check, LeftCurlyTests.NLOW_CASEBLOCK, MSG_NL);
	}

	public function testNLOW() {
		var check = new LeftCurlyCheck();
		check.option = LeftCurlyCheck.NLOW;
		assertNoMsg(check, LeftCurlyTests.TEST);
		assertNoMsg(check, LeftCurlyTests.TEST12);
		assertNoMsg(check, LeftCurlyTests.TEST16);
		assertNoMsg(check, LeftCurlyTests.NLOW_CASEBLOCK);
		assertMsg(check, LeftCurlyTests.TEST17, MSG_NLOW);
		assertMsg(check, LeftCurlyTests.TEST18, MSG_NL_SPLIT);
		assertMsg(check, LeftCurlyTests.TEST19, MSG_NL_SPLIT);
	}

	public function testReification() {
		var check = new LeftCurlyCheck();
		check.tokens = [LeftCurlyCheck.REIFICATION];
		assertMsg(check, LeftCurlyTests.MACRO_REIFICATION, MSG_EOL);
	}

	public function testIgnoreEmptySingleline() {
		var check = new LeftCurlyCheck();
		check.ignoreEmptySingleline = false;
		assertMsg(check, LeftCurlyTests.NO_FIELDS_CLASS, MSG_EOL);
		assertMsg(check, LeftCurlyTests.NO_FIELDS_MACRO, MSG_EOL);

		check.ignoreEmptySingleline = true;
		assertNoMsg(check, LeftCurlyTests.NO_FIELDS_CLASS);
		assertNoMsg(check, LeftCurlyTests.NO_FIELDS_MACRO);
	}
}

class LeftCurlyTests {
	public static inline var TEST:String = "
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

	public static inline var TEST1:String = "
	class Test {
		function test() {
			if (true)
			{
				return;
			}
		}
	}";

	public static inline var TEST2:String = "
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

	public static inline var TEST3:String = "
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

	public static inline var TEST4:String = "
	class Test {
		function test() {
			if (true) return { x:1,
				y:2,
				z:3 };
		}
	}";

	public static inline var TEST5:String = "
	class Test {
		function test() {
			for (i in 0...10)
			{
				return i;
			}
		}
	}";

	public static inline var TEST6:String = "
	class Test {
		function test() {
			for (i in 0...10) if (i < 5) {
				return i;
			}
		}
	}";

	public static inline var TEST7:String = "
	class Test {
		function test() {
			while (true) { return i; }
		}
	}";

	public static inline var TEST8:String = "
	class Test {
		function test() {
			while (true) {
				return i;
			}
		}
	}";

	public static inline var TEST9:String = "
	class Test {
		function test() {
			for (i in 0....10) return i;
		}
	}";

	public static inline var TEST10:String = "
	class Test
	{
		function test() {
			if (true) return;
		}
	}";

	public static inline var TEST12:String = "
	class Test {
		function test() {
			var struct = {x:10, y:10, z:20};
		}
	}";

	public static inline var TEST13:String = "
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

	public static inline var TEST14:String = "
	typedef Test = {
		x:Int,
		y:Int,
		z:Int,
		point:{x:Int, y:Int, z:Int}
	}";

	public static inline var TEST15:String = "
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

	public static inline var TEST16:String = "
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

	public static inline var TEST17:String = "
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

	public static inline var TEST18:String = "
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

	public static inline var TEST19:String = "
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

	public static inline var NL_CASEBLOCK:String = "
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

	public static inline var EOL_CASEBLOCK:String = "
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

	public static inline var NLOW_CASEBLOCK:String = "
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

	public static inline var MACRO_REIFICATION:String = "
	class Test {
		public function test(val:Int) {
			var str = 'Hello, world';
			var expr = macro for (i in 0...10) trace($v{str});
			var e = macro ${str}.toLowerCase();
		}
	}";

	public static inline var NO_FIELDS_CLASS:String = "
	class Test {}
	";

	public static inline var NO_FIELDS_MACRO:String = "
	class Test {
		var definition = macro class Font extends flash.text.Font {};
	}";

	public static inline var ISSUE_97:String = "
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
}