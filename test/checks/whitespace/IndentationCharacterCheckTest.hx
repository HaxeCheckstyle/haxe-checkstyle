package checks.whitespace;

import checkstyle.checks.whitespace.IndentationCharacterCheck;

class IndentationCharacterCheckTest extends CheckTestCase {

	public function testWrongIndentation() {
		assertMsg(new IndentationCharacterCheck(), IndentationTests.TEST1, 'Wrong indentation character (should be tab)');
	}

	public function testCorrectIndentation() {
		assertNoMsg(new IndentationCharacterCheck(), IndentationTests.TEST2);
	}

	public function testConfigurableIndentation() {
		var check = new IndentationCharacterCheck();
		check.character = "space";

		assertMsg(check, IndentationTests.TEST3, 'Wrong indentation character (should be space)');
	}

	public function testMultilineIfIndentation() {
		assertNoMsg(new IndentationCharacterCheck(), IndentationTests.TEST4);
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