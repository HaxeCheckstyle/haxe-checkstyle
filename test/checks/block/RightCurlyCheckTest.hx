package checks.block;

import checkstyle.checks.block.RightCurlyCheck;

class RightCurlyCheckTest extends CheckTestCase {

	static inline var MSG_ALONE:String = 'Right curly should be alone on a new line';
	static inline var MSG_NOT_SAME_LINE:String = 'Right curly should not be on same line as left curly';
	static inline var MSG_SAME_LINE:String = 'Right curly should be on same line as following block (e.g. "} else" or "} catch")';

	public function testCorrectAloneOrSingleLine() {
		var check = new RightCurlyCheck();
		assertNoMsg(check, RightCurlyTests.ALONE_OR_SINGLELINE_CORRECT);

		assertNoMsg(check, RightCurlyTests.SINGLELINE_IF);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_FUNCTION);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_FOR);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_WHILE);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_TRY_CATCH);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_INTERFACE);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_CLASS);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_TYPEDEF);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_SWITCH);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_CASE);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_OBJECT);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_ABSTRACT);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_ENUM);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_NESTED_OBJECT);

		assertNoMsg(check, RightCurlyTests.MACRO_REIFICATION);

		assertNoMsg(check, RightCurlyTests.ALONE_IF);
		assertNoMsg(check, RightCurlyTests.ALONE_FUNCTION);
		assertNoMsg(check, RightCurlyTests.ALONE_FOR);
		assertNoMsg(check, RightCurlyTests.ALONE_WHILE);
		assertNoMsg(check, RightCurlyTests.ALONE_TRY_CATCH);
		assertNoMsg(check, RightCurlyTests.ALONE_INTERFACE);
		assertNoMsg(check, RightCurlyTests.ALONE_CLASS);
		assertNoMsg(check, RightCurlyTests.ALONE_TYPEDEF);
		assertNoMsg(check, RightCurlyTests.ALONE_SWITCH);
		assertNoMsg(check, RightCurlyTests.ALONE_CASE);
		assertNoMsg(check, RightCurlyTests.ALONE_OBJECT);
		assertNoMsg(check, RightCurlyTests.ALONE_ABSTRACT);
		assertNoMsg(check, RightCurlyTests.ALONE_ENUM);
		assertNoMsg(check, RightCurlyTests.ALONE_NESTED_OBJECT);
	}

	public function testIncorrectAloneOrSingleLine() {
		var check = new RightCurlyCheck();
		assertMsg(check, RightCurlyTests.SAMELINE_IF, MSG_ALONE);
		assertMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH, MSG_ALONE);
		assertMsg(check, RightCurlyTests.SAMELINE_NESTED_OBJECT, MSG_ALONE);
	}

	public function testCorrectSame() {
		var check = new RightCurlyCheck();
		check.option = RightCurlyCheck.SAME;
		assertNoMsg(check, RightCurlyTests.SAMELINE_IF);
		assertNoMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH);
		assertNoMsg(check, RightCurlyTests.SAMELINE_NESTED_OBJECT);

		assertNoMsg(check, RightCurlyTests.ALONE_FUNCTION);
		assertNoMsg(check, RightCurlyTests.ALONE_FOR);
		assertNoMsg(check, RightCurlyTests.ALONE_WHILE);
		assertNoMsg(check, RightCurlyTests.ALONE_INTERFACE);
		assertNoMsg(check, RightCurlyTests.ALONE_CLASS);
		assertNoMsg(check, RightCurlyTests.ALONE_TYPEDEF);
		assertNoMsg(check, RightCurlyTests.ALONE_SWITCH);
		assertNoMsg(check, RightCurlyTests.ALONE_CASE);
		assertNoMsg(check, RightCurlyTests.ALONE_OBJECT);
		assertNoMsg(check, RightCurlyTests.ALONE_ABSTRACT);
		assertNoMsg(check, RightCurlyTests.ALONE_ENUM);
		assertNoMsg(check, RightCurlyTests.ALONE_NESTED_OBJECT);

		assertNoMsg(check, RightCurlyTests.MACRO_REIFICATION);
	}

	public function testIncorrectSame() {
		var check = new RightCurlyCheck();
		check.option = RightCurlyCheck.SAME;
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_FOR, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_WHILE, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_TRY_CATCH, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_INTERFACE, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_CLASS, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_TYPEDEF, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_SWITCH, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_CASE, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_OBJECT, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_ABSTRACT, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_ENUM, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_NESTED_OBJECT, MSG_NOT_SAME_LINE);

		assertMsg(check, RightCurlyTests.ALONE_IF, MSG_SAME_LINE);
		assertMsg(check, RightCurlyTests.ALONE_TRY_CATCH, MSG_SAME_LINE);
	}

	public function testCorrectAlone() {
		var check = new RightCurlyCheck();
		check.option = RightCurlyCheck.ALONE;
		assertNoMsg(check, RightCurlyTests.ALONE_IF);
		assertNoMsg(check, RightCurlyTests.ALONE_FOR);
		assertNoMsg(check, RightCurlyTests.ALONE_WHILE);
		assertNoMsg(check, RightCurlyTests.ALONE_FUNCTION);
		assertNoMsg(check, RightCurlyTests.ALONE_INTERFACE);
		assertNoMsg(check, RightCurlyTests.ALONE_CLASS);
		assertNoMsg(check, RightCurlyTests.ALONE_TYPEDEF);
		assertNoMsg(check, RightCurlyTests.ALONE_SWITCH);
		assertNoMsg(check, RightCurlyTests.ALONE_CASE);
		assertNoMsg(check, RightCurlyTests.ALONE_OBJECT);
		assertNoMsg(check, RightCurlyTests.ALONE_ABSTRACT);
		assertNoMsg(check, RightCurlyTests.ALONE_ENUM);
		assertNoMsg(check, RightCurlyTests.ALONE_NESTED_OBJECT);

		assertNoMsg(check, RightCurlyTests.MACRO_REIFICATION);
	}

	public function testIncorrectAlone() {
		var check = new RightCurlyCheck();
		check.option = RightCurlyCheck.ALONE;
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_FUNCTION, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_FOR, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_WHILE, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_TRY_CATCH, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_INTERFACE, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_CLASS, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_TYPEDEF, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_SWITCH, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_CASE, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_OBJECT, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_ABSTRACT, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_ENUM, MSG_NOT_SAME_LINE);
		assertMsg(check, RightCurlyTests.SINGLELINE_NESTED_OBJECT, MSG_NOT_SAME_LINE);

		assertMsg(check, RightCurlyTests.SAMELINE_IF, MSG_ALONE);
		assertMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH, MSG_ALONE);
		assertMsg(check, RightCurlyTests.SAMELINE_NESTED_OBJECT, MSG_ALONE);
	}

	public function testTokenIF() {
		var check = new RightCurlyCheck();
		check.tokens = [RightCurlyCheck.IF];
		assertNoMsg(check, RightCurlyTests.SINGLELINE_IF);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_FOR);
		assertMsg(check, RightCurlyTests.SAMELINE_IF, MSG_ALONE);
		assertNoMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH);
		assertNoMsg(check, RightCurlyTests.ALONE_IF);
		assertNoMsg(check, RightCurlyTests.ALONE_FOR);

		check.option = RightCurlyCheck.SAME;
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, MSG_NOT_SAME_LINE);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_FOR);
		assertNoMsg(check, RightCurlyTests.SAMELINE_IF);
		assertNoMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH);
		assertMsg(check, RightCurlyTests.ALONE_IF, MSG_SAME_LINE);
		assertNoMsg(check, RightCurlyTests.ALONE_FOR);

		check.option = RightCurlyCheck.ALONE;
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, MSG_NOT_SAME_LINE);
		assertNoMsg(check, RightCurlyTests.SINGLELINE_FOR);
		assertMsg(check, RightCurlyTests.SAMELINE_IF, MSG_ALONE);
		assertNoMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH);
		assertNoMsg(check, RightCurlyTests.ALONE_IF);
		assertNoMsg(check, RightCurlyTests.ALONE_FOR);
	}

	public function testTokenMacroReification() {
		var check = new RightCurlyCheck();
		check.tokens = [RightCurlyCheck.REIFICATION];
		assertNoMsg(check, RightCurlyTests.MACRO_REIFICATION);

		check.option = RightCurlyCheck.SAME;
		assertMsg(check, RightCurlyTests.MACRO_REIFICATION, MSG_NOT_SAME_LINE);

		check.option = RightCurlyCheck.ALONE;
		assertMsg(check, RightCurlyTests.MACRO_REIFICATION, MSG_NOT_SAME_LINE);
	}
}

class RightCurlyTests {
	public static inline var ALONE_OR_SINGLELINE_CORRECT:String = "
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

	public static inline var SINGLELINE_IF:String = "
	class Test {
		function test() {
			if (true) { return; } else { return; }
		}
	}";

	public static inline var SAMELINE_IF:String = "
	class Test {
		function test() {
			if (true) {
				return;
			} else {
				return;
			}
		}
	}";

	public static inline var ALONE_IF:String = "
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

	public static inline var SINGLELINE_FUNCTION:String = "
	class Test {
		function test() { trace ('test'); }
	}";

	public static inline var ALONE_FUNCTION:String = "
	class Test {
		function test() {
			trace ('test');
		}
	}";

	public static inline var SINGLELINE_FOR:String = "
	class Test {
		function test() {
			for (i in 0...100) { trace ('$i'); }
		}
	}";

	public static inline var ALONE_FOR:String = "
	class Test {
		function test() {
			for (i in 0...100) {
				trace ('$i');
			}
		}
	}";

	public static inline var SINGLELINE_WHILE:String = "
	class Test {
		function test() {
			while (true) { trace ('test'); }
		}
	}";

	public static inline var ALONE_WHILE:String = "
	class Test {
		function test() {
			while (true) {
				trace ('test');
			}
		}
	}";

	public static inline var SINGLELINE_TRY_CATCH:String = "
	class Test {
		function test() {
			try { trace ('test'); } catch (e:Dynamic) {}
		}
	}";

	public static inline var SAMELINE_TRY_CATCH:String = "
	class Test {
		function test() {
			try {
				trace ('test');
			} catch (e:Dynamic) {
			}
		}
	}";

	public static inline var ALONE_TRY_CATCH:String = "
	class Test {
		function test() {
			try {
				trace ('test');
			}
			catch (e:Dynamic) {
			}
		}
	}";

	public static inline var SINGLELINE_INTERFACE:String = "
	interface Test { function test(); }";

	public static inline var ALONE_INTERFACE:String = "
	interface Test {
		function test();
	}";

	public static inline var SINGLELINE_CLASS:String = "
	class Test { function test() {}; }";

	public static inline var ALONE_CLASS:String = "
	class Test {
		function test() {
		};
	}";

	public static inline var SINGLELINE_TYPEDEF:String = "
	typedef Test = { x:Int, y:Int, z:Int }";

	public static inline var ALONE_TYPEDEF:String = "
	typedef Test = {
		x:Int,
		y:Int,
		z:Int
	}";

	public static inline var SINGLELINE_SWITCH:String = "
	class Test {
		function test(val:Bool) {
			switch (val) { case true: return; default: trace(val); }
		}
	}";

	public static inline var ALONE_SWITCH:String = "
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

	public static inline var SINGLELINE_CASE:String = "
	class Test {
		function test(val:Bool) {
			switch (val) {
				case true: return;
				case false: { trace(val); return; }
				default: { trace('unreachable'); return; }
			}
		}
	}";

	public static inline var ALONE_CASE:String = "
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

	public static inline var SINGLELINE_OBJECT:String = "
	class Test {
		function test(val:Bool) {
			var p = { x:100, y: 10, z: 2 };
		}
	}";

	public static inline var ALONE_OBJECT:String = "
	class Test {
		function test() {
			var p = {
				x:100,
				y: 10,
				z: 2
			};
		}
	}";

	public static inline var SINGLELINE_ABSTRACT:String = "
	abstract Test(String) { @:from public static function fromString(value:String) { return new Test('Hello $value'); } }";

	public static inline var ALONE_ABSTRACT:String = "
	abstract Test(String) {
		@:from
		public static function fromString(value:String) {
			return new Test('Hello $value');
		}
	}";

	public static inline var SINGLELINE_ENUM:String = "
	enum Test { Monday; Tuesday; Wednesday; Thursday; Friday; Weekend(day:String); }";

	public static inline var ALONE_ENUM:String = "
	enum Test {
		Monday;
		Tuesday;
		Wednesday;
		Thursday;
		Friday;
		Weekend(day:String);
	}";

	public static inline var SINGLELINE_NESTED_OBJECT:String = "
	class Test {
		public function test() {
			var l = {
				p1 : { x:100, y: 10, z: 2 },
				p2 : { x:200, y: 50, z: 2 }
			};
			var l2 = [
				{ x:100, y: 10, z: 2 },
				{ x:200, y: 50, z: 2 }];
		}
	}";

	public static inline var SAMELINE_NESTED_OBJECT:String = "
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
					z: 2
				}};
			var l2 = [
				{
					x:100,
					y: 10,
					z: 2
				},
				{
					x:200,
					y: 50,
					z: 2
				}];
		}
	}";

	public static inline var ALONE_NESTED_OBJECT:String = "
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
					z: 2
				}
			};
			var l2 = [
				{
					x:100,
					y: 10,
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

	public static inline var MACRO_REIFICATION:String = "
	class Test {
		public function test(val:Int) {
			var str = 'Hello, world';
			var expr = macro for (i in 0...10) trace($v{str});
			var e = macro ${str}.toLowerCase();
		}
	}";
}