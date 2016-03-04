package checks.block;

import checkstyle.checks.block.RightCurlyCheck;

class RightCurlyCheckTest extends CheckTestCase {

	public function testCorrectAloneOrSingleLine() {
		var check = new RightCurlyCheck();
		assertMsg(check, RightCurlyTests.ALONE_OR_SINGLELINE_CORRECT, '');

		assertMsg(check, RightCurlyTests.SINGLELINE_IF, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_FUNCTION, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_FOR, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_WHILE, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_TRY_CATCH, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_INTERFACE, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_CLASS, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_TYPEDEF, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_SWITCH, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_CASE, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_OBJECT, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_ABSTRACT, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_ENUM, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_NESTED_OBJECT, '');

		assertMsg(check, RightCurlyTests.MACRO_REIFICATION, '');

		assertMsg(check, RightCurlyTests.ALONE_IF, '');
		assertMsg(check, RightCurlyTests.ALONE_FUNCTION, '');
		assertMsg(check, RightCurlyTests.ALONE_FOR, '');
		assertMsg(check, RightCurlyTests.ALONE_WHILE, '');
		assertMsg(check, RightCurlyTests.ALONE_TRY_CATCH, '');
		assertMsg(check, RightCurlyTests.ALONE_INTERFACE, '');
		assertMsg(check, RightCurlyTests.ALONE_CLASS, '');
		assertMsg(check, RightCurlyTests.ALONE_TYPEDEF, '');
		assertMsg(check, RightCurlyTests.ALONE_SWITCH, '');
		assertMsg(check, RightCurlyTests.ALONE_CASE, '');
		assertMsg(check, RightCurlyTests.ALONE_OBJECT, '');
		assertMsg(check, RightCurlyTests.ALONE_ABSTRACT, '');
		assertMsg(check, RightCurlyTests.ALONE_ENUM, '');
		assertMsg(check, RightCurlyTests.ALONE_NESTED_OBJECT, '');
	}

	public function testIncorrectAloneOrSingleLine() {
		var check = new RightCurlyCheck();
		assertMsg(check, RightCurlyTests.SAMELINE_IF, 'Right curly should be alone on a new line');
		assertMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH, 'Right curly should be alone on a new line');
		assertMsg(check, RightCurlyTests.SAMELINE_NESTED_OBJECT, 'Right curly should be alone on a new line');
	}

	public function testCorrectSame() {
		var check = new RightCurlyCheck();
		check.option = RightCurlyCheck.SAME;
		assertMsg(check, RightCurlyTests.SAMELINE_IF, '');
		assertMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH, '');
		assertMsg(check, RightCurlyTests.SAMELINE_NESTED_OBJECT, '');

		assertMsg(check, RightCurlyTests.ALONE_FUNCTION, '');
		assertMsg(check, RightCurlyTests.ALONE_FOR, '');
		assertMsg(check, RightCurlyTests.ALONE_WHILE, '');
		assertMsg(check, RightCurlyTests.ALONE_INTERFACE, '');
		assertMsg(check, RightCurlyTests.ALONE_CLASS, '');
		assertMsg(check, RightCurlyTests.ALONE_TYPEDEF, '');
		assertMsg(check, RightCurlyTests.ALONE_SWITCH, '');
		assertMsg(check, RightCurlyTests.ALONE_CASE, '');
		assertMsg(check, RightCurlyTests.ALONE_OBJECT, '');
		assertMsg(check, RightCurlyTests.ALONE_ABSTRACT, '');
		assertMsg(check, RightCurlyTests.ALONE_ENUM, '');
		assertMsg(check, RightCurlyTests.ALONE_NESTED_OBJECT, '');

		assertMsg(check, RightCurlyTests.MACRO_REIFICATION, '');
	}

	public function testIncorrectSame() {
		var check = new RightCurlyCheck();
		check.option = RightCurlyCheck.SAME;
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_FOR, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_WHILE, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_TRY_CATCH, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_INTERFACE, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_CLASS, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_TYPEDEF, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_SWITCH, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_CASE, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_OBJECT, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_ABSTRACT, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_ENUM, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_NESTED_OBJECT, 'Right curly should not be on same line as left curly');

		assertMsg(check, RightCurlyTests.ALONE_IF, 'Right curly should be on same line as following block (e.g. "} else" or "} catch")');
		assertMsg(check, RightCurlyTests.ALONE_TRY_CATCH, 'Right curly should be on same line as following block (e.g. "} else" or "} catch")');
	}

	public function testCorrectAlone() {
		var check = new RightCurlyCheck();
		check.option = RightCurlyCheck.ALONE;
		assertMsg(check, RightCurlyTests.ALONE_IF, '');
		assertMsg(check, RightCurlyTests.ALONE_FOR, '');
		assertMsg(check, RightCurlyTests.ALONE_WHILE, '');
		assertMsg(check, RightCurlyTests.ALONE_FUNCTION, '');
		assertMsg(check, RightCurlyTests.ALONE_INTERFACE, '');
		assertMsg(check, RightCurlyTests.ALONE_CLASS, '');
		assertMsg(check, RightCurlyTests.ALONE_TYPEDEF, '');
		assertMsg(check, RightCurlyTests.ALONE_SWITCH, '');
		assertMsg(check, RightCurlyTests.ALONE_CASE, '');
		assertMsg(check, RightCurlyTests.ALONE_OBJECT, '');
		assertMsg(check, RightCurlyTests.ALONE_ABSTRACT, '');
		assertMsg(check, RightCurlyTests.ALONE_ENUM, '');
		assertMsg(check, RightCurlyTests.ALONE_NESTED_OBJECT, '');

		assertMsg(check, RightCurlyTests.MACRO_REIFICATION, '');
	}

	public function testIncorrectAlone() {
		var check = new RightCurlyCheck();
		check.option = RightCurlyCheck.ALONE;
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_FUNCTION, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_FOR, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_WHILE, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_TRY_CATCH, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_INTERFACE, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_CLASS, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_TYPEDEF, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_SWITCH, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_CASE, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_OBJECT, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_ABSTRACT, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_ENUM, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_NESTED_OBJECT, 'Right curly should not be on same line as left curly');

		assertMsg(check, RightCurlyTests.SAMELINE_IF, 'Right curly should be alone on a new line');
		assertMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH, 'Right curly should be alone on a new line');
		assertMsg(check, RightCurlyTests.SAMELINE_NESTED_OBJECT, 'Right curly should be alone on a new line');
	}

	public function testTokenIF() {
		var check = new RightCurlyCheck();
		check.tokens = [RightCurlyCheck.IF];
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, '');
		assertMsg(check, RightCurlyTests.SINGLELINE_FOR, '');
		assertMsg(check, RightCurlyTests.SAMELINE_IF, 'Right curly should be alone on a new line');
		assertMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH, '');
		assertMsg(check, RightCurlyTests.ALONE_IF, '');
		assertMsg(check, RightCurlyTests.ALONE_FOR, '');

		check.option = RightCurlyCheck.SAME;
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_FOR, '');
		assertMsg(check, RightCurlyTests.SAMELINE_IF, '');
		assertMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH, '');
		assertMsg(check, RightCurlyTests.ALONE_IF, 'Right curly should be on same line as following block (e.g. "} else" or "} catch")');
		assertMsg(check, RightCurlyTests.ALONE_FOR, '');

		check.option = RightCurlyCheck.ALONE;
		assertMsg(check, RightCurlyTests.SINGLELINE_IF, 'Right curly should not be on same line as left curly');
		assertMsg(check, RightCurlyTests.SINGLELINE_FOR, '');
		assertMsg(check, RightCurlyTests.SAMELINE_IF, 'Right curly should be alone on a new line');
		assertMsg(check, RightCurlyTests.SAMELINE_TRY_CATCH, '');
		assertMsg(check, RightCurlyTests.ALONE_IF, '');
		assertMsg(check, RightCurlyTests.ALONE_FOR, '');
	}

	public function testTokenMacroReification() {
		var check = new RightCurlyCheck();
		check.tokens = [RightCurlyCheck.REIFICATION];
		assertMsg(check, RightCurlyTests.MACRO_REIFICATION, '');

		check.option = RightCurlyCheck.SAME;
		assertMsg(check, RightCurlyTests.MACRO_REIFICATION, 'Right curly should not be on same line as left curly');

		check.option = RightCurlyCheck.ALONE;
		assertMsg(check, RightCurlyTests.MACRO_REIFICATION, 'Right curly should not be on same line as left curly');
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