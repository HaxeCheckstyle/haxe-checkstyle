package ;

import checkstyle.checks.block.NeedBracesCheck;

class NeedBracesCheckTest extends CheckTestCase {

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
		assertMsg(check, NeedBracesTests.TEST1, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST2, 'No braces used for body of "else"');
		assertMsg(check, NeedBracesTests.TEST4, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST6, 'No braces used for body of "for"');
		assertMsg(check, NeedBracesTests.TEST7, 'No braces used for body of "while"');
		assertMsg(check, NeedBracesTests.TEST11, 'No braces used for body of "if"');
	}

	public function testNoAllowSingleLine() {
		var check = new NeedBracesCheck ();
		check.allowSingleLineStatement = false;

		assertMsg(check, NeedBracesTests.TEST, 'Body of "while" on same line');
		assertMsg(check, NeedBracesTests.TEST1, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST2, 'No braces used for body of "else"');
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, 'No braces used for body of "for"');
		assertMsg(check, NeedBracesTests.TEST7, 'No braces used for body of "while"');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, 'Body of "for" on same line');
		assertMsg(check, NeedBracesTests.TEST10, 'Body of "if" on same line');
		assertMsg(check, NeedBracesTests.TEST11, 'Body of "else" on same line');
		assertMsg(check, NeedBracesTests.TEST12, 'No braces used for body of "else"');
		assertMsg(check, NeedBracesTests.TEST13, 'Body of "else" on same line');
		assertMsg(check, NeedBracesTests.TEST14, 'No braces used for body of "else"');
		assertMsg(check, NeedBracesTests.INTERFACE_DEF, '');
	}

	public function testTokenFOR() {
		var check = new NeedBracesCheck ();
		check.tokens = ["FOR"];

		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST1, '');
		assertMsg(check, NeedBracesTests.TEST2, '');
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, '');
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, 'No braces used for body of "for"');
		assertMsg(check, NeedBracesTests.TEST7, '');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST11, '');
		assertMsg(check, NeedBracesTests.TEST12, '');
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, '');

		check.allowSingleLineStatement = false;
		assertMsg(check, NeedBracesTests.TEST, 'Body of "for" on same line');
		assertMsg(check, NeedBracesTests.TEST9, 'Body of "for" on same line');
	}

	public function testTokenIF() {
		var check = new NeedBracesCheck ();
		check.tokens = ["IF"];

		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST1, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST2, 'No braces used for body of "else"');
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, '');
		assertMsg(check, NeedBracesTests.TEST7, '');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST11, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST12, 'No braces used for body of "else"');
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, 'No braces used for body of "else"');

		check.allowSingleLineStatement = false;
		assertMsg(check, NeedBracesTests.TEST, 'Body of "if" on same line');
		assertMsg(check, NeedBracesTests.TEST10, 'Body of "if" on same line');
		assertMsg(check, NeedBracesTests.TEST11, 'Body of "else" on same line');
		assertMsg(check, NeedBracesTests.TEST13, 'Body of "else" on same line');
		assertMsg(check, NeedBracesTests.TEST14, 'No braces used for body of "else"');
	}

	public function testTokenELSE_IF() {
		var check = new NeedBracesCheck ();
		check.tokens = ["IF", "ELSE_IF"];

		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST1, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST2, 'No braces used for body of "else"');
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, '');
		assertMsg(check, NeedBracesTests.TEST7, '');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST11, 'No braces used for body of "if"');
		assertMsg(check, NeedBracesTests.TEST12, '');
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, '');

		check.allowSingleLineStatement = false;
		assertMsg(check, NeedBracesTests.TEST, 'Body of "if" on same line');
		assertMsg(check, NeedBracesTests.TEST10, 'Body of "if" on same line');
		assertMsg(check, NeedBracesTests.TEST11, 'Body of "else" on same line');
		assertMsg(check, NeedBracesTests.TEST12, 'No braces used for body of "else"');
		assertMsg(check, NeedBracesTests.TEST13, 'Body of "else" on same line');
		assertMsg(check, NeedBracesTests.TEST14, 'No braces used for body of "else"');
	}

	public function testTokenWHILE() {
		var check = new NeedBracesCheck ();
		check.tokens = ["WHILE"];

		assertMsg(check, NeedBracesTests.TEST, '');
		assertMsg(check, NeedBracesTests.TEST1, '');
		assertMsg(check, NeedBracesTests.TEST2, '');
		assertMsg(check, NeedBracesTests.TEST3, '');
		assertMsg(check, NeedBracesTests.TEST4, '');
		assertMsg(check, NeedBracesTests.TEST5, '');
		assertMsg(check, NeedBracesTests.TEST6, '');
		assertMsg(check, NeedBracesTests.TEST7, 'No braces used for body of "while"');
		assertMsg(check, NeedBracesTests.TEST8, '');
		assertMsg(check, NeedBracesTests.TEST9, '');
		assertMsg(check, NeedBracesTests.TEST10, '');
		assertMsg(check, NeedBracesTests.TEST11, '');
		assertMsg(check, NeedBracesTests.TEST12, '');
		assertMsg(check, NeedBracesTests.TEST13, '');
		assertMsg(check, NeedBracesTests.TEST14, '');

		check.allowSingleLineStatement = false;
		assertMsg(check, NeedBracesTests.TEST, 'Body of "while" on same line');
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