package checks.whitespace;

import checkstyle.checks.whitespace.EmptyLinesCheck;

class EmptyLinesCheckTest extends CheckTestCase {

	static inline var MSG_TOO_MANY:String = 'Too many consecutive empty lines (> 1)';
	static inline var MSG_AFTER_COMMENT:String = 'Empty line not allowed after comment(s)';

	public function testDefaultEmptyLines() {
		var msg = checkMessage(EmptyLinesTests.TEST1, new EmptyLinesCheck());
		assertEquals(msg, MSG_TOO_MANY);
	}

	public function testCorrectEmptyLines() {
		var msg = checkMessage(EmptyLinesTests.TEST2, new EmptyLinesCheck());
		assertEquals(msg, '');
	}

	public function testConfigurableEmptyLines() {
		var check = new EmptyLinesCheck();
		check.max = 2;

		var msg = checkMessage(EmptyLinesTests.TEST3, check);
		assertEquals(msg, '');
	}

	public function testEmptyLineAfterSingleLineComment() {
		var check = new EmptyLinesCheck();
		check.allowEmptyLineAfterSingleLineComment = false;

		var msg = checkMessage(EmptyLinesTests.TEST4, check);
		assertEquals(msg, MSG_AFTER_COMMENT);

		msg = checkMessage(EmptyLinesTests.TEST5, check);
		assertEquals(msg, MSG_AFTER_COMMENT);
	}

	public function testEmptyLineAfterMultiLineComment() {
		var check = new EmptyLinesCheck();
		check.allowEmptyLineAfterMultiLineComment = false;

		var msg = checkMessage(EmptyLinesTests.TEST6, check);
		assertEquals(msg, MSG_AFTER_COMMENT);

		msg = checkMessage(EmptyLinesTests.TEST7, check);
		assertEquals(msg, MSG_AFTER_COMMENT);
	}

	public function testAllowEmptyLineAfterComment() {
		var check = new EmptyLinesCheck();

		var msg = checkMessage(EmptyLinesTests.TEST4, check);
		assertEquals(msg, '');

		var msg = checkMessage(EmptyLinesTests.TEST5, check);
		assertEquals(msg, '');

		var msg = checkMessage(EmptyLinesTests.TEST6, check);
		assertEquals(msg, '');

		msg = checkMessage(EmptyLinesTests.TEST7, check);
		assertEquals(msg, '');
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