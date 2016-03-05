package checks.whitespace;

import checkstyle.checks.whitespace.SeparatorWrapCheck;

class SeparatorWrapCheckTest extends CheckTestCase {

	static inline var MSG_COMMA_EOL:String = 'Token "," must be at the end of the line';
	static inline var MSG_DOT_EOL:String = 'Token "." must be at the end of the line';

	static inline var MSG_COMMA_NL:String = 'Token "," must be on a new line';
	static inline var MSG_DOT_NL:String = 'Token "." must be on a new line';

	public function testCorrectWrap() {
		var check = new SeparatorWrapCheck();
		assertNoMsg(check, SeparatorWrapTests.CORRECT_WRAP);
		assertNoMsg(check, SeparatorWrapTests.CORRECT_NOWRAP);
		assertNoMsg(check, SeparatorWrapTests.EOL_WRAP_ARRAY);
		assertNoMsg(check, SeparatorWrapTests.EOL_WRAP_IMPORT);
		assertNoMsg(check, SeparatorWrapTests.NOWRAP_ARRAY);
		assertNoMsg(check, SeparatorWrapTests.NOWRAP_CALL);
		assertNoMsg(check, SeparatorWrapTests.NOWRAP_IMPORT);
	}

	public function testIncorrectWrap() {
		var check = new SeparatorWrapCheck();
		assertMsg(check, SeparatorWrapTests.NL_WRAP_FUNC, MSG_COMMA_EOL);
		assertMsg(check, SeparatorWrapTests.NL_WRAP_OBJECT_DECL, MSG_COMMA_EOL);
		assertMsg(check, SeparatorWrapTests.NL_WRAP_ARRAY, MSG_COMMA_EOL);
		assertMsg(check, SeparatorWrapTests.NL_WRAP_CALL, MSG_DOT_EOL);
		assertMsg(check, SeparatorWrapTests.NL_WRAP_IMPORT, MSG_DOT_EOL);
	}

	public function testOptionNL() {
		var check = new SeparatorWrapCheck();
		check.option = "nl";
		assertNoMsg(check, SeparatorWrapTests.NL_WRAP_FUNC);
		assertNoMsg(check, SeparatorWrapTests.NL_WRAP_OBJECT_DECL);
		assertNoMsg(check, SeparatorWrapTests.NL_WRAP_ARRAY);
		assertNoMsg(check, SeparatorWrapTests.NL_WRAP_CALL);
		assertNoMsg(check, SeparatorWrapTests.NL_WRAP_IMPORT);

		assertNoMsg(check, SeparatorWrapTests.CORRECT_NOWRAP);
		assertNoMsg(check, SeparatorWrapTests.NOWRAP_ARRAY);
		assertNoMsg(check, SeparatorWrapTests.NOWRAP_CALL);
		assertNoMsg(check, SeparatorWrapTests.NOWRAP_IMPORT);

		assertMsg(check, SeparatorWrapTests.CORRECT_WRAP, MSG_COMMA_NL);
		assertMsg(check, SeparatorWrapTests.EOL_WRAP_ARRAY, MSG_COMMA_NL);
		assertMsg(check, SeparatorWrapTests.EOL_WRAP_IMPORT, MSG_DOT_NL);
	}
}

class SeparatorWrapTests {
	public static inline var CORRECT_WRAP:String = "
	package checkstyle.
			tests;
	import haxe.
		macro.
		Expr;

	class Test {
		function test(param1:String,
				param2:String) {
			var x = { x: 100, // x-coordinate
				y: 100, /* y-coordinate */
				z: 20
			};
		}

		@SuppressWarnings('checkstyle:SeparatorWrap')
		function test(param1:String
				, param2:String) {
			var x = { x: 100
				, y: 100
				, z: 20
			};
		}
	}

	typedef Test = {
		x:Int,
		y:Int,
		z:Int
	}";

	public static inline var CORRECT_NOWRAP:String = "
	package checkstyle.tests;
	import haxe.macro.Expr;

	class Test {
		function test(param1:String, param2:String) {
			var x = { x: 100, y: 100, z: 20 };
		}
	}

	typedef Test = { x:Int, y:Int, z:Int }";

	public static inline var NL_WRAP_FUNC:String = "
	class Test {
		function test(param1:String
				, param2:String) {
		}
	}";

	public static inline var NL_WRAP_OBJECT_DECL:String = "
	class Test {
		function test(param1:String, param2:String) {
			var x={ x: 100
				, y: 100
				, z: 20 };
		}
	}";

	public static inline var NOWRAP_ARRAY:String = "
	class Test {
		var test:Array<String>=[1, 2, 3, 4];
	}";

	public static inline var EOL_WRAP_ARRAY:String = "
	class Test {
		var test:Array<String>=[1,
			2,
			3,
			4];
	}";

	public static inline var NL_WRAP_ARRAY:String = "
	class Test {
		var test:Array<String>=[1
			, 2
			, 3
			, 4];
	}";

	public static inline var NOWRAP_CALL:String = "
	class Test {
		function test(a:String) {
			a.substr(0, 10);
		}
	}";

	public static inline var EOL_WRAP_CALL:String = "
	class Test {
		function test(a:String) {
			// invalid haxe code, won't compile
			a.
				substr(0, 10);
		}
	}";

	public static inline var NL_WRAP_CALL:String = "
	class Test {
		function test(a:String) {
			a
				.substr(0, 10);
		}
	}";

	public static inline var EOL_WRAP_IMPORT:String = "
	package checkstyle.
			tests;
	import haxe.
			macro.
			Expr;
	";

	public static inline var NOWRAP_IMPORT:String = "
	package checkstyle.tests;
	import haxe.macro.Expr;
	";

	public static inline var NL_WRAP_IMPORT:String = "
	package checkstyle
			.tests;
	import haxe
			.macro
			.Expr;
	";
}