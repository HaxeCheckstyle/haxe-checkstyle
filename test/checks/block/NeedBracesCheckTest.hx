package checks.block;

import checkstyle.checks.block.NeedBracesCheck;

class NeedBracesCheckTest extends CheckTestCase {

	static inline var PREFIX:String = 'No braces used for body of ';
	static inline var MSG_IF:String = PREFIX + '"if"';
	static inline var MSG_ELSE:String = PREFIX + '"else"';
	static inline var MSG_FOR:String = PREFIX + '"for"';
	static inline var MSG_WHILE:String = PREFIX + '"while"';

	static inline var MSG_SAME_LINE_IF:String = 'Body of "if" on same line';
	static inline var MSG_SAME_LINE_ELSE:String = 'Body of "else" on same line';
	static inline var MSG_SAME_LINE_FOR:String = 'Body of "for" on same line';
	static inline var MSG_SAME_LINE_WHILE:String = 'Body of "while" on same line';

	public function testCorrectBraces() {
		var check = new NeedBracesCheck ();
		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST12, '');
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, '');
		assertMsg(check, NeedBracesTests.INTERFACE_DEF, '');
	}

	public function testWrongBraces() {
		var check = new NeedBracesCheck ();
		assertMsg(check, NeedBracesTests.TEST1, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST2, MSG_ELSE);
		assertMsg(check, NeedBracesTests.TEST4, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST6, MSG_FOR);
		assertMsg(check, NeedBracesTests.TEST7, MSG_WHILE);
		assertMsg(check, NeedBracesTests.TEST11, MSG_IF);
	}

	public function testNoAllowSingleLine() {
		var check = new NeedBracesCheck ();
		check.allowSingleLineStatement = false;

		assertMsg(check, NeedBracesTests.TEST, MSG_SAME_LINE_WHILE);
		assertMsg(check, NeedBracesTests.TEST1, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST2, MSG_ELSE);
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, MSG_FOR);
		assertMsg(check, NeedBracesTests.TEST7, MSG_WHILE);
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, MSG_SAME_LINE_FOR);
		assertMsg(check, NeedBracesTests.TEST10, MSG_SAME_LINE_IF);
		assertMsg(check, NeedBracesTests.TEST11, MSG_SAME_LINE_ELSE);
		assertMsg(check, NeedBracesTests.TEST12, MSG_ELSE);
		assertMsg(check, NeedBracesTests.TEST13, MSG_SAME_LINE_ELSE);
		assertMsg(check, NeedBracesTests.TEST14, MSG_ELSE);
		assertMsg(check, NeedBracesTests.INTERFACE_DEF, '');
	}

	public function testTokenFor() {
		var check = new NeedBracesCheck ();
		check.tokens = ["FOR"];

		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST1, '');
		assertMsg(check, NeedBracesTests.TEST2, '');
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, '');
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, MSG_FOR);
		assertMsg(check, NeedBracesTests.TEST7, '');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST11, '');
		assertMsg(check, NeedBracesTests.TEST12, '');
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, '');

		check.allowSingleLineStatement = false;
		assertMsg(check, NeedBracesTests.TEST, MSG_SAME_LINE_FOR);
		assertMsg(check, NeedBracesTests.TEST9, MSG_SAME_LINE_FOR);
	}

	public function testTokenIf() {
		var check = new NeedBracesCheck ();
		check.tokens = ["IF"];

		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST1, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST2, MSG_ELSE);
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, '');
		assertMsg(check, NeedBracesTests.TEST7, '');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST11, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST12, MSG_ELSE);
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, MSG_ELSE);

		check.allowSingleLineStatement = false;
		assertMsg(check, NeedBracesTests.TEST, MSG_SAME_LINE_IF);
		assertMsg(check, NeedBracesTests.TEST10, MSG_SAME_LINE_IF);
		assertMsg(check, NeedBracesTests.TEST11, MSG_SAME_LINE_ELSE);
		assertMsg(check, NeedBracesTests.TEST13, MSG_SAME_LINE_ELSE);
		assertMsg(check, NeedBracesTests.TEST14, MSG_ELSE);
	}

	public function testTokenElseIf() {
		var check = new NeedBracesCheck ();
		check.tokens = ["IF", "ELSE_IF"];

		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST1, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST2, MSG_ELSE);
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, '');
		assertMsg(check, NeedBracesTests.TEST7, '');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST11, MSG_IF);
		assertMsg(check, NeedBracesTests.TEST12, '');
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, '');

		check.allowSingleLineStatement = false;
		assertMsg(check, NeedBracesTests.TEST, MSG_SAME_LINE_IF);
		assertMsg(check, NeedBracesTests.TEST10, MSG_SAME_LINE_IF);
		assertMsg(check, NeedBracesTests.TEST11, MSG_SAME_LINE_ELSE);
		assertMsg(check, NeedBracesTests.TEST12, MSG_ELSE);
		assertMsg(check, NeedBracesTests.TEST13, MSG_SAME_LINE_ELSE);
		assertMsg(check, NeedBracesTests.TEST14, MSG_ELSE);
	}

	public function testTokenWhile() {
		var check = new NeedBracesCheck ();
		check.tokens = ["WHILE"];

		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST1, '');
		assertMsg(check, NeedBracesTests.TEST2, '');
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, '');
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, '');
		assertMsg(check, NeedBracesTests.TEST7, MSG_WHILE);
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST11, '');
		assertMsg(check, NeedBracesTests.TEST12, '');
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, '');

		check.allowSingleLineStatement = false;
		assertMsg(check, NeedBracesTests.TEST, MSG_SAME_LINE_WHILE);
	}
}

class NeedBracesTests {
	public static inline var TEST:String = "
	class Test {
		function test() {
			if (true) return;

			if (true) return;
			else return;

			if (true) return;
			else if (false) return;

			if (true) {
				return;
			}

			for (i in 0...10) return i;

			try {
				while (true) return;
			}
			catch(e:Dynamic) {
				trace(e);
			}
		}
		@SuppressWarnings('checkstyle:NeedBraces')
		function test1() {
			if (true)
				return;

			for (i in 0...10)
				return i;

			while (true)
				return;
		}
	}";

	public static inline var TEST1:String = "
	class Test {
		function test() {
			if (true)
				return;
		}
	}";

	public static inline var TEST2:String = "
	class Test {
		function test() {
			if (true) return;
			else
				return;
		}
	}";

	public static inline var TEST3:String = "
	class Test {
		function test() {
			if (true) {
				return;
			}
			else {
				return;
			}
		}
	}";

	public static inline var TEST4:String = "
	class Test {
		function test() {
			if (true) return { x:1,
				y:2,
				z:3 };
		}
	}";

	public static inline var TEST5:String = "
	class Test {
		function test() {
			for (i in 0...10) {
				return i;
			}
		}
	}";

	public static inline var TEST6:String = "
	class Test {
		function test() {
			for (i in 0...10) if (i < 5) {
				return i;
			}
		}
	}";

	public static inline var TEST7:String = "
	class Test {
		function test() {
			while (true)
				return i;
		}
	}";

	public static inline var TEST8:String = "
	class Test {
		function test() {
			while (true) {
				return i;
			}
		}
	}";

	public static inline var TEST9:String = "
	class Test {
		function test() {
			for (i in 0....10) return i;
		}
	}";

	public static inline var TEST10:String = "
	class Test {
		function test() {
			if (true) return;
		}
	}";

	public static inline var TEST11:String = "
	class Test {
		function test() {
			if (true)
				return;
			else return;
		}
	}";

	public static inline var TEST12:String = "
	class Test {
		function test() {
			if (true) return;
			else if (false) {
				return;
			}
		}
	}";

	public static inline var TEST13:String = "
	class Test {
		function test() {
			if (true) return;
			else if (false) { return; }
		}
	}";

	public static inline var TEST14:String = "
	class Test {
		function test() {
			if (condition) {
				someAction();
			} else if (condition2) {
				anotherAction();
			}
		}
	}";

	public static inline var INTERFACE_DEF:String = "
	interface Test {
		function test();
	}";
}