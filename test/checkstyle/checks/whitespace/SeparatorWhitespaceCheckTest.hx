package checkstyle.checks.whitespace;

class SeparatorWhitespaceCheckTest extends CheckTestCase<SeparatorWhitespaceCheckTests> {
	static inline var MSG_AFTER:String = 'SeparatorWhitespace policy "after" violated by ","';

	@Test
	public function testCorrectSeparatorWhitespace() {
		var check = new SeparatorWhitespaceCheck();
		assertNoMsg(check, CORRECT_WHITESPACE);
	}

	@Test
	public function testIncorrectSeparatorWhitespaceToken() {
		var check = new SeparatorWhitespaceCheck();
		check.commaPolicy = AFTER;
		assertMsg(check, COMMA_WHITESPACE_NONE, MSG_AFTER);
		assertMsg(check, WHITESPACE_AROUND, MSG_AFTER);
	}

	@Test
	public function testWhitespaceAround() {
		var check = new SeparatorWhitespaceCheck();
		check.commaPolicy = AROUND;
		assertNoMsg(check, WHITESPACE_AROUND);
	}

	@Test
	public function testWhitespaceNone() {
		var check = new SeparatorWhitespaceCheck();
		check.commaPolicy = NONE;
		assertNoMsg(check, COMMA_WHITESPACE_NONE);
	}

	@Test
	public function testIgnore() {
		var check = new SeparatorWhitespaceCheck();
		check.dotPolicy = IGNORE;
		check.commaPolicy = IGNORE;
		check.semicolonPolicy = IGNORE;

		assertNoMsg(check, CORRECT_WHITESPACE);
		assertNoMsg(check, COMMA_WHITESPACE_NONE);
		assertNoMsg(check, WHITESPACE_AROUND);
	}
}

@:enum
abstract SeparatorWhitespaceCheckTests(String) to String {
	var CORRECT_WHITESPACE = "
	import haxe.macro.*;

	class Test {
		function test() {
			var a = create(1).add(2).add(3);
			var a = create(1)
				.add(2)
				.add(3);
			var a = create(1).add(2).add(3);
			var a = [1, 2, 3, 4];
			var a = [1,
				2,
				3,
				4];
			var a = [1
				, 2
				, 3
				, 4];
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
	var COMMA_WHITESPACE_NONE = "
	typedef Test = { x:Int,y:Int,z:Int }
	typedef Test2 = { x:Int,
	    y:Int,
	    z:Int }
	typedef Test3 = { x:Int
		,y:Int
		,z:Int }
	";
	var WHITESPACE_AROUND = "
	typedef Test = { x:String , y:Int , z:Int }
	class Test2 {
		function test() {
			a = create(1).add(2).add(3);
			a = [ 1 , 2 , 3 ];
		}
	}
	";
}