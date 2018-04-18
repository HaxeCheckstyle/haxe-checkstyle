package checks.whitespace;

import checkstyle.CheckMessage.SeverityLevel;
import checkstyle.checks.whitespace.IndentationCharacterCheck;

class IndentationCharacterCheckTest extends CheckTestCase<IndentationCheckTests> {

	@Test
	public function testWrongIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST1, "Wrong indentation character (should be tab)");
	}

	@Test
	public function testCorrectIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TEST2);
	}

	@Test
	public function testConfigurableIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		check.character = SPACE;

		assertMsg(check, TEST3, "Wrong indentation character (should be space)");
	}

	@Test
	public function testMultilineIfIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TEST4);
	}

	@Test
	public function testFileBoundaryIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, TEST5_1);
		assertMsg(check, TEST5_2, "Wrong indentation character (should be tab)");
	}

	@Test
	public function testMultilineQuoteIndentation() {
		var check = new IndentationCharacterCheck();
		check.severity = SeverityLevel.INFO;
		assertMsg(check, TEST6, "Wrong indentation character (should be tab)");
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

	var TEST5_1 =
	"class Test {
		public function new() {
			// breaking comment with quote '
		}
	}";

	var TEST5_2 =
	"class Test {
		public function new() {
		  // bad indentation here
		}
	}";

	var TEST6 =
	"class Test {
		public function new() {
			// breaking comment with quote '
		  // bad indentation here
		}
	}";
}