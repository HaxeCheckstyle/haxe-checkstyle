package checks.whitespace;

import checkstyle.checks.whitespace.WhitespaceAroundCheck;

class WhitespaceAroundCheckTest extends CheckTestCase<WhitespaceAroundCheckTests> {

	static inline var MSG_EQUALS:String = 'No whitespace around "="';

	public function testCorrectWhitespace() {
		var check = new WhitespaceAroundCheck();
		assertNoMsg(check, CORRECT_WHITESPACE_AROUND);
		assertNoMsg(check, ISSUE_70);
		assertNoMsg(check, ISSUE_71);
		assertNoMsg(check, ISSUE_72);
		assertNoMsg(check, ISSUE_77);
		assertNoMsg(check, ISSUE_80);
		assertNoMsg(check, ISSUE_81);
		assertNoMsg(check, ISSUE_98);
		assertNoMsg(check, MINUS_CONSTANT);
		assertNoMsg(check, CONDITIONAL_STAR_IMPORT_ISSUE_160);
		assertNoMsg(check, CONDITIONAL_ELSE_STAR_IMPORT);
		assertNoMsg(check, CONDITIONAL_ELSEIF_STAR_IMPORT);
	}

	public function testIncorrectWhitespace() {
		var check = new WhitespaceAroundCheck();
		assertMsg(check, NO_WHITESPACE_OBJECT_DECL, MSG_EQUALS);
		assertMsg(check, NO_WHITESPACE_TYPEDEF, MSG_EQUALS);
		assertMsg(check, ISSUE_59, MSG_EQUALS);
		assertMsg(check, ISSUE_63, MSG_EQUALS);
	}

	public function testIncorrectWhitespaceToken() {
		var check = new WhitespaceAroundCheck();
		check.tokens = ["="];
		assertNoMsg(check, CORRECT_WHITESPACE_AROUND);
		assertMsg(check, NO_WHITESPACE_GT, MSG_EQUALS);
		assertMsg(check, NO_WHITESPACE_OBJECT_DECL, MSG_EQUALS);
		assertMsg(check, NO_WHITESPACE_TYPEDEF, MSG_EQUALS);
		assertMsg(check, NO_WHITESPACE_VAR_INIT, MSG_EQUALS);

		check.tokens = [">"];
		assertNoMsg(check, CORRECT_WHITESPACE_AROUND);
		assertNoMsg(check, NO_WHITESPACE_VAR_INIT);
		assertNoMsg(check, NO_WHITESPACE_GT);
	}

	public function testStarImport() {
		var check = new WhitespaceAroundCheck();
		check.tokens = ["*"];
		assertNoMsg(check, ISSUE_70);
		assertNoMsg(check, CONDITIONAL_STAR_IMPORT_ISSUE_160);
		assertNoMsg(check, CONDITIONAL_ELSE_STAR_IMPORT);
		assertNoMsg(check, CONDITIONAL_ELSEIF_STAR_IMPORT);
	}
}

@:enum
abstract WhitespaceAroundCheckTests(String) to String {
	var CORRECT_WHITESPACE_AROUND = "
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

	var NO_WHITESPACE_OBJECT_DECL = "
	class Test {
		function test(param1:String, param2:String) {
			var x={ x: 100, y: 100,z: 20 };
		}
	}";

	var NO_WHITESPACE_TYPEDEF = "
	typedef Test ={
		x:Int,
		y:Int,z:Int
	}";

	var NO_WHITESPACE_VAR_INIT = "
	class Test {
		function test(param1:String, param2:String) {
			var test:Array<String>=[];
		}
	}";

	var NO_WHITESPACE_GT = "
	class Test {
		function test(param1:String, param2:String) {
			var test:Array<String>= [];
		}
	}";

	var ISSUE_58 = "
	class Test {
		public function new() {
			var x:Int, y:Int;
		}
	}";

	var ISSUE_59 = "
	typedef Test=Int
	";

	var ISSUE_63 = "
	typedef Test =#if true Int #else String #end
	";

	var ISSUE_70 = "
		import haxe.macro.*;
	";

	var ISSUE_71 = "
		class Test {
		function foo<T, X>() {
			trace((null : Array<Int, String>));
		}
	}";

	var ISSUE_72 = "
	abstract Test<T>(Array<T>) {}
	";

	var ISSUE_77 = "
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

	var ISSUE_80 = "
	interface Test implements Dynamic {}
	";

	var ISSUE_81 = "
	class Test {
		function foo() {
			do a++ while (true);
			do ++a while (true);
		}
	}";

	var ISSUE_98 = "
	class Test {
		// °öäüßÖÄÜ@łĸŋđđðſðæµ”“„¢«»Ø→↓←Ŧ¶€Ł}][{¬½¼³²
		var test:Int = 0;
	}";

	var MINUS_CONSTANT = "
	class Test {
		function test() {
			if (re.match(line) && line.indexOf('//') == -1) {
				log('Tab after non-space character, Use space for aligning', i + 1, line.length, null, Reflect.field(SeverityLevel, severity));
				return -1;
			}
			a = 1 - -2;
			return - 1;
		}
	}";

	var CONDITIONAL_STAR_IMPORT_ISSUE_160 = "
	#if macro
		import haxe.macro.*;
	#end";

	var CONDITIONAL_ELSEIF_STAR_IMPORT = "
	#if macro
		import haxe.macro.Type;
	#elseif neko
		import haxe.macro.*;
	#else
		import haxe.macro.*;
	#end
	import haxe.macro.Type;";

	var CONDITIONAL_ELSE_STAR_IMPORT = "
	#if macro
		import haxe.macro.Type;
	#else
		import haxe.macro.*;
	#end
	import haxe.macro.Type;";
}