package checks.whitespace;

import checkstyle.checks.whitespace.WhitespaceAfterCheck;

class WhitespaceAfterCheckTest extends CheckTestCase<WhitespaceAfterCheckTests> {

	static inline var MSG_COMMA:String = 'No whitespace after ","';
	static inline var MSG_EQUALS:String = 'No whitespace after "="';
	static inline var MSG_GREATER:String = 'No whitespace after ">"';

	public function testCorrectWhitespace() {
		var check = new WhitespaceAfterCheck();
		assertNoMsg(check, CORRECT_WHITESPACE_AFTER);
		assertNoMsg(check, ISSUE_57);
		assertNoMsg(check, ISSUE_58);
		assertNoMsg(check, ISSUE_59);
		assertNoMsg(check, ISSUE_63);
		assertNoMsg(check, ISSUE_64);
		assertNoMsg(check, ISSUE_65);
		assertNoMsg(check, ISSUE_66);
		assertNoMsg(check, ISSUE_67);
	}

	public function testIncorrectWhitespace() {
		var check = new WhitespaceAfterCheck();
		assertMsg(check, NO_WHITESPACE_FUNC, MSG_COMMA);
		assertMsg(check, NO_WHITESPACE_OBJECT_DECL, MSG_COMMA);
		assertMsg(check, NO_WHITESPACE_TYPEDEF, MSG_COMMA);
	}

	public function testIncorrectWhitespaceToken() {
		var check = new WhitespaceAfterCheck();
		check.tokens = ["="];
		assertNoMsg(check, CORRECT_WHITESPACE_AFTER);
		assertNoMsg(check, NO_WHITESPACE_FUNC);
		assertNoMsg(check, NO_WHITESPACE_GT);
		assertMsg(check, NO_WHITESPACE_OBJECT_DECL, MSG_EQUALS);
		assertMsg(check, NO_WHITESPACE_TYPEDEF, MSG_EQUALS);
		assertMsg(check, NO_WHITESPACE_VAR_INIT, MSG_EQUALS);

		check.tokens = [">"];
		assertNoMsg(check, CORRECT_WHITESPACE_AFTER);
		assertMsg(check, NO_WHITESPACE_VAR_INIT, MSG_GREATER);
		assertMsg(check, NO_WHITESPACE_GT, MSG_GREATER);
	}
}

@:enum
abstract WhitespaceAfterCheckTests(String) to String {
	var CORRECT_WHITESPACE_AFTER = "
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

	var NO_WHITESPACE_FUNC = "
	class Test {
		function test(param1:String,param2:String) {
		}
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

	var ISSUE_57 = "
	class Test {
		public function new() {
			trace(#if true cast #end 'text');
		}
	}";

	var ISSUE_58 = "
	class Test {
		public function new() {
			var x:Int, y:Int;
		}
	}";

	var ISSUE_59 = "
	typedef Test = Int
	";

	var ISSUE_63 = "
	typedef Test = #if true Int #else String #end
	";

	var ISSUE_64 = "
	class Test #if true extends Base #end {}
	";

	var ISSUE_65 = "
	class Test {
		function foo() {
			switch (0) {
				case 0, /*1,*/ 2:
				case _:
			}
		}
	}";

	var ISSUE_66 = "
	class Test {
		public inline function new<T>() {}
	}";

	var ISSUE_67 = "
	extern class Promise<T>
	{
		@:overload(function<T>(promise : Promise<T>) : Promise<T> {})
		@:overload(function<T>(thenable : Thenable<T>) : Promise<T> {})
		static function resolve<T>( value : T ) : Promise<T>;
	}";
}