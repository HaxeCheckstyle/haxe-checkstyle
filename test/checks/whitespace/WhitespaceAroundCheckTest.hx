package checks.whitespace;

import checkstyle.checks.whitespace.WhitespaceAroundCheck;

class WhitespaceAroundCheckTest extends CheckTestCase {

	public function testCorrectWhitespace() {
		var check = new WhitespaceAroundCheck();
		assertMsg(check, WhitespaceAroundTests.CORRECT_WHITESPACE_AROUND, '');
		assertMsg(check, WhitespaceAroundTests.ISSUE_70, '');
		assertMsg(check, WhitespaceAroundTests.ISSUE_71, '');
		assertMsg(check, WhitespaceAroundTests.ISSUE_72, '');
		assertMsg(check, WhitespaceAroundTests.ISSUE_77, '');
		assertMsg(check, WhitespaceAroundTests.ISSUE_80, '');
		assertMsg(check, WhitespaceAroundTests.ISSUE_98, '');
	}

	public function testIncorrectWhitespace() {
		var check = new WhitespaceAroundCheck();
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_OBJECT_DECL, 'No whitespace around "="');
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_TYPEDEF, 'No whitespace around "="');
		assertMsg(check, WhitespaceAroundTests.ISSUE_59, 'No whitespace around "="');
		assertMsg(check, WhitespaceAroundTests.ISSUE_63, 'No whitespace around "="');
	}

	public function testIncorrectWhitespaceToken() {
		var check = new WhitespaceAroundCheck();
		check.tokens = ["="];
		assertMsg(check, WhitespaceAroundTests.CORRECT_WHITESPACE_AROUND, '');
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_GT, 'No whitespace around "="');
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_OBJECT_DECL, 'No whitespace around "="');
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_TYPEDEF, 'No whitespace around "="');
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_VAR_INIT, 'No whitespace around "="');

		check.tokens = [">"];
		assertMsg(check, WhitespaceAroundTests.CORRECT_WHITESPACE_AROUND, '');
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_VAR_INIT, '');
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_GT, '');
	}
}

class WhitespaceAroundTests {
	public static inline var CORRECT_WHITESPACE_AROUND:String = "
	import haxe.macro.*;

	class Test {
		function test(param1:String, param2:String) {
			var x = { x: 100, y: 100,
				z: 20 * 10
			};
			var y:Array<String> = [];
		}
	}

	typedef Test = {
		x:Int,
		y:Int, z:Int
	}

	enum Test {
		Monday;
		Tuesday;
		Wednesday;
		Thursday;
		Friday; Weekend(day:String);
	}";

	public static inline var NO_WHITESPACE_OBJECT_DECL:String = "
	class Test {
		function test(param1:String, param2:String) {
			var x={ x: 100, y: 100,z: 20 };
		}
	}";

	public static inline var NO_WHITESPACE_TYPEDEF:String = "
	typedef Test ={
		x:Int,
		y:Int,z:Int
	}";

	public static inline var NO_WHITESPACE_VAR_INIT:String = "
	class Test {
		function test(param1:String, param2:String) {
			var test:Array<String>=[];
		}
	}";

	public static inline var NO_WHITESPACE_GT:String = "
	class Test {
		function test(param1:String, param2:String) {
			var test:Array<String>= [];
		}
	}";

	public static inline var ISSUE_58:String = "
	class Test {
		public function new() {
			var x:Int, y:Int;
		}
	}";

	public static inline var ISSUE_59:String = "
	typedef Test=Int
	";

	public static inline var ISSUE_63:String = "
	typedef Test =#if true Int #else String #end
	";

	public static inline var ISSUE_70:String = "
		import haxe.macro.*;
	";

	public static inline var ISSUE_71:String = "
		class Test {
		function foo<T, X>() {
			trace((null : Array<Int, String>));
		}
	}";

	public static inline var ISSUE_72:String = "
	abstract Test<T>(Array<T>) {}
	";

	public static inline var ISSUE_77:String = "
	// comment
	class Test // comment
	{ // comment
		function foo() // comment
		{ // comment
			switch ('Test') // comment
			{ // comment
			} // comment
		} // comment
	} // comment
	";

	public static inline var ISSUE_80:String = "
	interface Test implements Dynamic {}
	";

	public static inline var ISSUE_98:String = "
	class Test {
		// °öäüßÖÄÜ@łĸŋđđðſðæµ”“„¢«»Ø→↓←Ŧ¶€Ł}][{¬½¼³²
		var test:Int = 0;
	}";
}