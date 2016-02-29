package ;

import checkstyle.checks.whitespace.WhitespaceAroundCheck;

class WhitespaceAroundCheckTest extends CheckTestCase {

	public function testCorrectWhitespace() {
		var check = new WhitespaceAroundCheck();
		assertMsg(check, WhitespaceAroundTests.CORRECT_WHITESPACE_AROUND, '');
		assertMsg(check, WhitespaceAroundTests.ISSUE_70, '');
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
}