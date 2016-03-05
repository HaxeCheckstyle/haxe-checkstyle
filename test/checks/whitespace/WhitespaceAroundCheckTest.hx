package checks.whitespace;

import checkstyle.checks.whitespace.WhitespaceAroundCheck;

class WhitespaceAroundCheckTest extends CheckTestCase {

	static inline var MSG_EQUALS:String = 'No whitespace around "="';

	public function testCorrectWhitespace() {
		var check = new WhitespaceAroundCheck();
		assertNoMsg(check, WhitespaceAroundTests.CORRECT_WHITESPACE_AROUND);
		assertNoMsg(check, WhitespaceAroundTests.ISSUE_70);
		assertNoMsg(check, WhitespaceAroundTests.ISSUE_71);
		assertNoMsg(check, WhitespaceAroundTests.ISSUE_72);
		assertNoMsg(check, WhitespaceAroundTests.ISSUE_77);
		assertNoMsg(check, WhitespaceAroundTests.ISSUE_80);
		assertNoMsg(check, WhitespaceAroundTests.ISSUE_81);
		assertNoMsg(check, WhitespaceAroundTests.ISSUE_98);
		assertNoMsg(check, WhitespaceAroundTests.MINUS_CONSTANT);
	}

	public function testIncorrectWhitespace() {
		var check = new WhitespaceAroundCheck();
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_OBJECT_DECL, MSG_EQUALS);
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_TYPEDEF, MSG_EQUALS);
		assertMsg(check, WhitespaceAroundTests.ISSUE_59, MSG_EQUALS);
		assertMsg(check, WhitespaceAroundTests.ISSUE_63, MSG_EQUALS);
	}

	public function testIncorrectWhitespaceToken() {
		var check = new WhitespaceAroundCheck();
		check.tokens = ["="];
		assertNoMsg(check, WhitespaceAroundTests.CORRECT_WHITESPACE_AROUND);
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_GT, MSG_EQUALS);
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_OBJECT_DECL, MSG_EQUALS);
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_TYPEDEF, MSG_EQUALS);
		assertMsg(check, WhitespaceAroundTests.NO_WHITESPACE_VAR_INIT, MSG_EQUALS);

		check.tokens = [">"];
		assertNoMsg(check, WhitespaceAroundTests.CORRECT_WHITESPACE_AROUND);
		assertNoMsg(check, WhitespaceAroundTests.NO_WHITESPACE_VAR_INIT);
		assertNoMsg(check, WhitespaceAroundTests.NO_WHITESPACE_GT);
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

	public static inline var ISSUE_81:String = "
	class Test {
		function foo() {
			do a++ while (true);
			do ++a while (true);
		}
	}";

	public static inline var ISSUE_98:String = "
	class Test {
		// °öäüßÖÄÜ@łĸŋđđðſðæµ”“„¢«»Ø→↓←Ŧ¶€Ł}][{¬½¼³²
		var test:Int = 0;
	}";

	public static inline var MINUS_CONSTANT:String = "
	class Test {
		function test() {
			if (re.match(line) && line.indexOf('//') == -1) {
				log('Tab after non-space character. Use space for aligning', i + 1, line.length, null, Reflect.field(SeverityLevel, severity));
				return -1;
			}
			a = 1 - -2;
			return - 1;
		}
	}";
}