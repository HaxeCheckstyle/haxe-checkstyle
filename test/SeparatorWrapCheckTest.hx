package ;

import checkstyle.checks.SeparatorWrapCheck;

class SeparatorWrapCheckTest extends CheckTestCase {

	public function testCorrectWrap() {
		var check = new SeparatorWrapCheck();
		assertMsg(check, SeparatorWrapTests.CORRECT_WRAP, '');
		assertMsg(check, SeparatorWrapTests.CORRECT_NOWRAP, '');
		assertMsg(check, SeparatorWrapTests.EOL_WRAP_ARRAY, '');
		assertMsg(check, SeparatorWrapTests.EOL_WRAP_IMPORT, '');
		assertMsg(check, SeparatorWrapTests.NOWRAP_ARRAY, '');
		assertMsg(check, SeparatorWrapTests.NOWRAP_CALL, '');
		assertMsg(check, SeparatorWrapTests.NOWRAP_IMPORT, '');
	}

	public function testIncorrectWrap() {
		var check = new SeparatorWrapCheck();
		assertMsg(check, SeparatorWrapTests.NL_WRAP_FUNC, 'Token "," must be at the end of the line');
		assertMsg(check, SeparatorWrapTests.NL_WRAP_OBJECT_DECL, 'Token "," must be at the end of the line');
		assertMsg(check, SeparatorWrapTests.NL_WRAP_ARRAY, 'Token "," must be at the end of the line');
		assertMsg(check, SeparatorWrapTests.NL_WRAP_CALL, 'Token "." must be at the end of the line');
		assertMsg(check, SeparatorWrapTests.NL_WRAP_IMPORT, 'Token "." must be at the end of the line');
	}

	public function testOptionNL() {
		var check = new SeparatorWrapCheck();
		check.option = "nl";
		assertMsg(check, SeparatorWrapTests.NL_WRAP_FUNC, '');
		assertMsg(check, SeparatorWrapTests.NL_WRAP_OBJECT_DECL, '');
		assertMsg(check, SeparatorWrapTests.NL_WRAP_ARRAY, '');
		assertMsg(check, SeparatorWrapTests.NL_WRAP_CALL, '');
		assertMsg(check, SeparatorWrapTests.NL_WRAP_IMPORT, '');

		assertMsg(check, SeparatorWrapTests.CORRECT_NOWRAP, '');
		assertMsg(check, SeparatorWrapTests.NOWRAP_ARRAY, '');
		assertMsg(check, SeparatorWrapTests.NOWRAP_CALL, '');
		assertMsg(check, SeparatorWrapTests.NOWRAP_IMPORT, '');

		assertMsg(check, SeparatorWrapTests.CORRECT_WRAP, 'Token "." must on a new line');
		assertMsg(check, SeparatorWrapTests.EOL_WRAP_ARRAY, 'Token "," must on a new line');
		assertMsg(check, SeparatorWrapTests.EOL_WRAP_IMPORT, 'Token "." must on a new line');
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