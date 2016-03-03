package ;

import checkstyle.checks.whitespace.IndentationCharacterCheck;

class IndentationCharacterCheckTest extends CheckTestCase {

	public function testWrongIndentation() {
		var msg = checkMessage(IndentationTests.TEST1, new IndentationCharacterCheck());
		assertEquals(msg, 'Wrong indentation character (should be tab)');
	}

	public function testCorrectIndentation() {
		var msg = checkMessage(IndentationTests.TEST2, new IndentationCharacterCheck());
		assertEquals(msg, '');
	}

	public function testConfigurableIndentation() {
		var check = new IndentationCharacterCheck();
		check.character = "space";

		var msg = checkMessage(IndentationTests.TEST3, check);
		assertEquals(msg, 'Wrong indentation character (should be space)');
	}

	public function testMultilineIfIndentation() {
		var msg = checkMessage(IndentationTests.TEST4, new IndentationCharacterCheck());
		assertEquals(msg, '');
	}
}

class IndentationTests {
	public static inline var TEST1:String = "
	class Test {
		 var _a:Int;
		public function new() {}
	}";

	public static inline var TEST2:String =
	"class Test {
		var _a:Int;
		public function new() {}
	}";

	public static inline var TEST3:String =
	"class Test {
		public function new() {}
	}";

	public static inline var TEST4:String =
	"class Test {
		public function new() {
			if (actionType == 'STREET' ||
				(actionType == 'BASKET' && ( actionNumber == 2 || actionNumber == 4) )) {
				return BetAreaModel.STREET;
			}
		}
	}";
}