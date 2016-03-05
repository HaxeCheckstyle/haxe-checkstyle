package checks.whitespace;

import checkstyle.checks.whitespace.EmptyLinesCheck;

class EmptyLinesCheckTest extends CheckTestCase {

	static inline var MSG_TOO_MANY:String = 'Too many consecutive empty lines (> 1)';
	static inline var MSG_AFTER_COMMENT:String = 'Empty line not allowed after comment(s)';

	public function testDefaultEmptyLines() {
		assertMsg(new EmptyLinesCheck(), EmptyLinesTests.TEST1, MSG_TOO_MANY);
	}

	public function testCorrectEmptyLines() {
		assertNoMsg(new EmptyLinesCheck(), EmptyLinesTests.TEST2);
	}

	public function testConfigurableEmptyLines() {
		var check = new EmptyLinesCheck();
		check.max = 2;
		assertNoMsg(check, EmptyLinesTests.TEST3);
	}

	public function testEmptyLineAfterSingleLineComment() {
		var check = new EmptyLinesCheck();
		check.allowEmptyLineAfterSingleLineComment = false;

		assertMsg(check, EmptyLinesTests.TEST4, MSG_AFTER_COMMENT);
		assertMsg(check, EmptyLinesTests.TEST5, MSG_AFTER_COMMENT);
	}

	public function testEmptyLineAfterMultiLineComment() {
		var check = new EmptyLinesCheck();
		check.allowEmptyLineAfterMultiLineComment = false;

		assertMsg(check, EmptyLinesTests.TEST6, MSG_AFTER_COMMENT);
		assertMsg(check, EmptyLinesTests.TEST7, MSG_AFTER_COMMENT);
	}

	public function testAllowEmptyLineAfterComment() {
		assertNoMsg(new EmptyLinesCheck(), EmptyLinesTests.TEST4);
		assertNoMsg(new EmptyLinesCheck(), EmptyLinesTests.TEST5);
		assertNoMsg(new EmptyLinesCheck(), EmptyLinesTests.TEST6);
		assertNoMsg(new EmptyLinesCheck(), EmptyLinesTests.TEST7);
	}
}

class EmptyLinesTests {
	public static inline var TEST1:String = "
	class Test {
		var _a:Int;


	}";

	public static inline var TEST2:String =
	"class Test {
		public function new() {
			var b:Int;

		}
	}";

	public static inline var TEST3:String =
	"class Test {
		public function new() {
			var b:Int;


		}
	}";

	public static inline var TEST4:String =
	"class Test {

		// comments

		public function new() {
			var b:Int;
		}
	}";

	public static inline var TEST5:String =
	"class Test {

		// comments

		var a:Int;
	}";

	public static inline var TEST6:String =
	"class Test {

		/**
		 *comments
		 */

		var a:Int;
	}";

	public static inline var TEST7:String =
	"class Test {

		/**
		 *comments
		 */

		public function new() {
			var b:Int;
		}
	}";
}