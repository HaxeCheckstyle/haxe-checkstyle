package checks.whitespace;

import checkstyle.CheckMessage.SeverityLevel;
import checkstyle.checks.whitespace.IndentationCharacterCheck;

class IndentationCharacterCheckTest extends CheckTestCase<IndentationCheckTests> {

	public function testWrongIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST1, "Wrong indentation character (should be tab)");
	}

	public function testCorrectIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TEST2);
	}

	public function testConfigurableIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		check.character = SPACE;

		assertMsg(check, TEST3, "Wrong indentation character (should be space)");
	}

	public function testMultilineIfIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TEST4);
	}
}

@:enum
abstract IndentationCheckTests(String) to String {
	var TEST1 = "
	class Test {
		 static inline var INDENTATION_CHARACTER_CHECK_TEST:Int = 100;
		public function new() {}
	}";

	var TEST2 =
	"class Test {
		var a:Int;
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