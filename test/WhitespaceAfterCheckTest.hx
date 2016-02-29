package ;

import checkstyle.checks.whitespace.WhitespaceAfterCheck;

class WhitespaceAfterCheckTest extends CheckTestCase {

	public function testCorrectWhitespace() {
		var check = new WhitespaceAfterCheck();
		assertMsg(check, WhitespaceAfterTests.CORRECT_WHITESPACE_AFTER, '');
		assertMsg(check, WhitespaceAfterTests.ISSUE_57, '');
		assertMsg(check, WhitespaceAfterTests.ISSUE_58, '');
		assertMsg(check, WhitespaceAfterTests.ISSUE_59, '');
		assertMsg(check, WhitespaceAfterTests.ISSUE_63, '');
		assertMsg(check, WhitespaceAfterTests.ISSUE_64, '');
	}

	public function testIncorrectWhitespace() {
		var check = new WhitespaceAfterCheck();
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_FUNC, 'No whitespace after ","');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_OBJECT_DECL, 'No whitespace after ","');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_TYPEDEF, 'No whitespace after ","');
	}

	public function testIncorrectWhitespaceToken() {
		var check = new WhitespaceAfterCheck();
		check.tokens = ["="];
		assertMsg(check, WhitespaceAfterTests.CORRECT_WHITESPACE_AFTER, '');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_FUNC, '');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_GT, '');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_OBJECT_DECL, 'No whitespace after "="');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_TYPEDEF, 'No whitespace after "="');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_VAR_INIT, 'No whitespace after "="');

		check.tokens = [">"];
		assertMsg(check, WhitespaceAfterTests.CORRECT_WHITESPACE_AFTER, '');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_VAR_INIT, 'No whitespace after ">"');
		assertMsg(check, WhitespaceAfterTests.NO_WHITESPACE_GT, 'No whitespace after ">"');
	}
}

class WhitespaceAfterTests {
	public static inline var CORRECT_WHITESPACE_AFTER:String = "
	class Test {
		function test(param1:String, param2:String) {
			var x = { x: 100, y: 100,
				z: 20
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

	public static inline var NO_WHITESPACE_FUNC:String = "
	class Test {
		function test(param1:String,param2:String) {
		}
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

	public static inline var ISSUE_57:String = "
	class Test {
		public function new() {
			trace(#if true cast #end 'text');
		}
	}";

	public static inline var ISSUE_58:String = "
	class Test {
		public function new() {
			var x:Int, y:Int;
		}
	}";

	public static inline var ISSUE_59:String = "
		typedef Test = Int
	";

	public static inline var ISSUE_63:String = "
		typedef Test = #if true Int #else String #end
	";

	public static inline var ISSUE_64:String = "
		class Test #if true extends Base #end {}
	";
}