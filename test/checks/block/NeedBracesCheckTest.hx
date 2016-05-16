package checks.block;

import checkstyle.checks.block.NeedBracesCheck;

class NeedBracesCheckTest extends CheckTestCase<NeedBracesCheckTests> {

	static inline var PREFIX:String = "No braces used for body of ";
	static inline var MSG_IF:String = PREFIX + '"if"';
	static inline var MSG_ELSE:String = PREFIX + '"else"';
	static inline var MSG_FOR:String = PREFIX + '"for"';
	static inline var MSG_WHILE:String = PREFIX + '"while"';

	static inline var MSG_SAME_LINE_IF:String = 'Body of "if" on same line';
	static inline var MSG_SAME_LINE_ELSE:String = 'Body of "else" on same line';
	static inline var MSG_SAME_LINE_FOR:String = 'Body of "for" on same line';
	static inline var MSG_SAME_LINE_WHILE:String = 'Body of "while" on same line';

	public function testCorrectBraces() {
		var check = new NeedBracesCheck();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, TEST8);
		assertNoMsg(check, TEST9);
		assertNoMsg(check, TEST10);
		assertNoMsg(check, TEST12);
		assertNoMsg(check, TEST13);
		assertNoMsg(check, TEST14);
		assertNoMsg(check, INTERFACE_DEF);
	}

	public function testWrongBraces() {
		var check = new NeedBracesCheck();
		assertMsg(check, TEST1, MSG_IF);
		assertMsg(check, TEST2, MSG_ELSE);
		assertMsg(check, TEST4, MSG_IF);
		assertMsg(check, TEST6, MSG_FOR);
		assertMsg(check, TEST7, MSG_WHILE);
		assertMsg(check, TEST11, MSG_IF);
	}

	public function testNoAllowSingleLine() {
		var check = new NeedBracesCheck();
		check.allowSingleLineStatement = false;

		assertMsg(check, TEST, MSG_SAME_LINE_WHILE);
		assertMsg(check, TEST1, MSG_IF);
		assertMsg(check, TEST2, MSG_ELSE);
		assertNoMsg(check, TEST3);
		assertMsg(check, TEST4, MSG_IF);
		assertNoMsg(check, TEST5);
		assertMsg(check, TEST6, MSG_FOR);
		assertMsg(check, TEST7, MSG_WHILE);
		assertNoMsg(check, TEST8);
		assertMsg(check, TEST9, MSG_SAME_LINE_FOR);
		assertMsg(check, TEST10, MSG_SAME_LINE_IF);
		assertMsg(check, TEST11, MSG_SAME_LINE_ELSE);
		assertMsg(check, TEST12, MSG_SAME_LINE_IF);
		assertMsg(check, TEST13, MSG_SAME_LINE_IF);
		assertNoMsg(check, TEST14);
		assertNoMsg(check, INTERFACE_DEF);
		assertMsg(check, TEST16, MSG_SAME_LINE_ELSE);
	}

	public function testTokenFor() {
		var check = new NeedBracesCheck();
		check.tokens = [FOR];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertMsg(check, TEST6, MSG_FOR);
		assertNoMsg(check, TEST7);
		assertNoMsg(check, TEST8);
		assertNoMsg(check, TEST9);
		assertNoMsg(check, TEST10);
		assertNoMsg(check, TEST11);
		assertNoMsg(check, TEST12);
		assertNoMsg(check, TEST13);
		assertNoMsg(check, TEST14);

		check.allowSingleLineStatement = false;
		assertMsg(check, TEST, MSG_SAME_LINE_FOR);
		assertMsg(check, TEST9, MSG_SAME_LINE_FOR);
	}

	public function testTokenIf() {
		var check = new NeedBracesCheck();
		check.tokens = [IF];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, MSG_IF);
		assertMsg(check, TEST2, MSG_ELSE);
		assertNoMsg(check, TEST3);
		assertMsg(check, TEST4, MSG_IF);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, TEST6);
		assertNoMsg(check, TEST7);
		assertNoMsg(check, TEST8);
		assertNoMsg(check, TEST9);
		assertNoMsg(check, TEST10);
		assertMsg(check, TEST11, MSG_IF);
		assertNoMsg(check, TEST12);
		assertNoMsg(check, TEST13);
		assertNoMsg(check, TEST14);

		check.allowSingleLineStatement = false;
		assertMsg(check, TEST, MSG_SAME_LINE_IF);
		assertMsg(check, TEST10, MSG_SAME_LINE_IF);
		assertMsg(check, TEST11, MSG_SAME_LINE_ELSE);
		assertMsg(check, TEST13, MSG_SAME_LINE_IF);
		assertNoMsg(check, TEST14);
		assertMsg(check, TEST16, MSG_SAME_LINE_ELSE);
	}

	public function testTokenElseIf() {
		var check = new NeedBracesCheck();
		check.tokens = [IF, ELSE_IF];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, MSG_IF);
		assertMsg(check, TEST2, MSG_ELSE);
		assertNoMsg(check, TEST3);
		assertMsg(check, TEST4, MSG_IF);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, TEST6);
		assertNoMsg(check, TEST7);
		assertNoMsg(check, TEST8);
		assertNoMsg(check, TEST9);
		assertNoMsg(check, TEST10);
		assertMsg(check, TEST11, MSG_IF);
		assertNoMsg(check, TEST12);
		assertNoMsg(check, TEST13);
		assertNoMsg(check, TEST14);

		check.allowSingleLineStatement = false;
		assertMsg(check, TEST, MSG_SAME_LINE_IF);
		assertMsg(check, TEST10, MSG_SAME_LINE_IF);
		assertMsg(check, TEST11, MSG_SAME_LINE_ELSE);
		assertMsg(check, TEST12, MSG_SAME_LINE_IF);
		assertMsg(check, TEST13, MSG_SAME_LINE_IF);
		assertNoMsg(check, TEST14);
		assertNoMsg(check, TEST15);
		assertMsg(check, TEST16, MSG_SAME_LINE_ELSE);
	}

	public function testTokenWhile() {
		var check = new NeedBracesCheck();
		check.tokens = [WHILE];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, TEST6);
		assertMsg(check, TEST7, MSG_WHILE);
		assertNoMsg(check, TEST8);
		assertNoMsg(check, TEST9);
		assertNoMsg(check, TEST10);
		assertNoMsg(check, TEST11);
		assertNoMsg(check, TEST12);
		assertNoMsg(check, TEST13);
		assertNoMsg(check, TEST14);

		check.allowSingleLineStatement = false;
		assertMsg(check, TEST, MSG_SAME_LINE_WHILE);
	}
}

@:enum
abstract NeedBracesCheckTests(String) to String {
	var TEST = "
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

	var TEST1 = "
	class Test {
		function test() {
			if (true)
				return;
		}
	}";

	var TEST2 = "
	class Test {
		function test() {
			if (true) return;
			else
				return;
		}
	}";

	var TEST3 = "
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

	var TEST4 = "
	class Test {
		function test() {
			if (true) return { x:1,
				y:2,
				z:3 };
		}
	}";

	var TEST5 = "
	class Test {
		function test() {
			for (i in 0...10) {
				return i;
			}
		}
	}";

	var TEST6 = "
	class Test {
		function test() {
			for (i in 0...10) if (i < 5) {
				return i;
			}
		}
	}";

	var TEST7 = "
	class Test {
		function test() {
			while (true)
				return i;
		}
	}";

	var TEST8 = "
	class Test {
		function test() {
			while (true) {
				return i;
			}
		}
	}";

	var TEST9 = "
	class Test {
		function test() {
			for (i in 0....10) return i;
		}
	}";

	var TEST10 = "
	class Test {
		function test() {
			if (true) return;
		}
	}";

	var TEST11 = "
	class Test {
		function test() {
			if (true)
				return;
			else return;
		}
	}";

	var TEST12 = "
	class Test {
		function test() {
			if (true) return;
			else if (false) {
				return;
			}
		}
	}";

	var TEST13 = "
	class Test {
		function test() {
			if (true) return;
			else if (false) { return; }
		}
	}";

	var TEST14 = "
	class Test {
		function test() {
			if (condition) {
				someAction();
			} else if (condition2) {
				anotherAction();
			}
		}
	}";

	var TEST15 = "
	class Test {
		public function test(a:Bool, b:Bool) {
		   if (a) {

		   }
		   else if (!b) {

		   }
		}
	}";

	var TEST16 = "
	class Test {
		function test() {
			if (true) {
				return;
			}
			else return;
		}
	}";

	var INTERFACE_DEF = "
	interface Test {
		function test();
	}";
}