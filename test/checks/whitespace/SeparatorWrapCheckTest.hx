package checks.whitespace;

import checkstyle.checks.whitespace.SeparatorWrapCheck;

class SeparatorWrapCheckTest extends CheckTestCase<SeparatorWrapCheckTests> {

	static inline var MSG_COMMA_EOL:String = 'Token "," must be at the end of the line';
	static inline var MSG_DOT_EOL:String = 'Token "." must be at the end of the line';

	static inline var MSG_COMMA_NL:String = 'Token "," must be on a new line';
	static inline var MSG_DOT_NL:String = 'Token "." must be on a new line';

	public function testCorrectWrap() {
		var check = new SeparatorWrapCheck();
		assertNoMsg(check, CORRECT_WRAP);
		assertNoMsg(check, CORRECT_NOWRAP);
		assertNoMsg(check, EOL_WRAP_ARRAY);
		assertNoMsg(check, EOL_WRAP_IMPORT);
		assertNoMsg(check, NOWRAP_ARRAY);
		assertNoMsg(check, NOWRAP_CALL);
		assertNoMsg(check, NOWRAP_IMPORT);
	}

	public function testIncorrectWrap() {
		var check = new SeparatorWrapCheck();
		assertMsg(check, NL_WRAP_FUNC, MSG_COMMA_EOL);
		assertMsg(check, NL_WRAP_OBJECT_DECL, MSG_COMMA_EOL);
		assertMsg(check, NL_WRAP_ARRAY, MSG_COMMA_EOL);
		assertMsg(check, NL_WRAP_CALL, MSG_DOT_EOL);
		assertMsg(check, NL_WRAP_IMPORT, MSG_DOT_EOL);
	}

	public function testOptionNL() {
		var check = new SeparatorWrapCheck();
		check.option = NL;
		assertNoMsg(check, NL_WRAP_FUNC);
		assertNoMsg(check, NL_WRAP_OBJECT_DECL);
		assertNoMsg(check, NL_WRAP_ARRAY);
		assertNoMsg(check, NL_WRAP_CALL);
		assertNoMsg(check, NL_WRAP_IMPORT);

		assertNoMsg(check, CORRECT_NOWRAP);
		assertNoMsg(check, NOWRAP_ARRAY);
		assertNoMsg(check, NOWRAP_CALL);
		assertNoMsg(check, NOWRAP_IMPORT);

		assertMsg(check, CORRECT_WRAP, MSG_COMMA_NL);
		assertMsg(check, EOL_WRAP_ARRAY, MSG_COMMA_NL);
		assertMsg(check, EOL_WRAP_IMPORT, MSG_DOT_NL);
	}
}

@:enum
abstract SeparatorWrapCheckTests(String) to String {
	var CORRECT_WRAP = "
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

	var CORRECT_NOWRAP = "
	package checkstyle.tests;
	import haxe.macro.Expr;

	class Test {
		function test(param1:String, param2:String) {
			var x = { x: 100, y: 100, z: 20 };
		}
	}

	typedef Test = { x:Int, y:Int, z:Int }";

	var NL_WRAP_FUNC = "
	class Test {
		function test(param1:String
				, param2:String) {
		}
	}";

	var NL_WRAP_OBJECT_DECL = "
	class Test {
		function test(param1:String, param2:String) {
			var x={ x: 100
				, y: 100
				, z: 20 };
		}
	}";

	var NOWRAP_ARRAY = "
	class Test {
		var test:Array<String>=[1, 2, 3, 4];
	}";

	var EOL_WRAP_ARRAY = "
	class Test {
		var test:Array<String>=[1,
			2,
			3,
			4];
	}";

	var NL_WRAP_ARRAY = "
	class Test {
		var test:Array<String>=[1
			, 2
			, 3
			, 4];
	}";

	var NOWRAP_CALL = "
	class Test {
		function test(a:String) {
			a.substr(0, 10);
		}
	}";

	var EOL_WRAP_CALL = "
	class Test {
		function test(a:String) {
			// invalid haxe code, won't compile
			a.
				substr(0, 10);
		}
	}";

	var NL_WRAP_CALL = "
	class Test {
		function test(a:String) {
			a
				.substr(0, 10);
		}
	}";

	var EOL_WRAP_IMPORT = "
	package checkstyle.
			tests;
	import haxe.
			macro.
			Expr;
	";

	var NOWRAP_IMPORT = "
	package checkstyle.tests;
	import haxe.macro.Expr;
	";

	var NL_WRAP_IMPORT = "
	package checkstyle
			.tests;
	import haxe
			.macro
			.Expr;
	";
}