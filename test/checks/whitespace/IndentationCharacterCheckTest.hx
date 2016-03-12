package checks.whitespace;

import checkstyle.checks.whitespace.IndentationCharacterCheck;

class IndentationCharacterCheckTest extends CheckTestCase<IndentationCheckTests> {

	public function testWrongIndentation() {
		assertMsg(new IndentationCharacterCheck(), TEST1, "Wrong indentation character (should be tab)");
	}

	public function testCorrectIndentation() {
		assertNoMsg(new IndentationCharacterCheck(), TEST2);
	}

	public function testConfigurableIndentation() {
		var check = new IndentationCharacterCheck();
		check.character = SPACE;

		assertMsg(check, TEST3, "Wrong indentation character (should be space)");
	}

	public function testMultilineIfIndentation() {
		assertNoMsg(new IndentationCharacterCheck(), TEST4);
	}
}

@:enum
abstract IndentationCheckTests(String) to String {
	var TEST1 = "
	class Test {
		 var _a:Int;
		public function new() {}
	}";

	var TEST2 =
	"class Test {
		var _a:Int;
		public function new() {}
	}";

	var TEST3 =
	"class Test {
		public function new() {}
	}";

	var TEST4 =
	"class Test {
		public function new() {
			if (actionType == 'STREET' ||
				(actionType == 'BASKET' && ( actionNumber == 2 || actionNumber == 4) )) {
				return BetAreaModel.STREET;
			}
		}
	}";
}