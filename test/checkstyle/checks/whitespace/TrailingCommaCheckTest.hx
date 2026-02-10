package checkstyle.checks.whitespace;

class TrailingCommaCheckTest extends CheckTestCase<TrailingCommaCheckTests> {
	static inline var OBJECT_MSG:String = "Missing trailing comma in multiline object literal";
	static inline var ARRAY_MSG:String = "Missing trailing comma in multiline array literal";

	function configuredCheck():TrailingCommaCheck {
		var check = new TrailingCommaCheck();
		check.enforceObjectLiterals = true;
		check.enforceArrayLiterals = true;
		return check;
	}

	@Test
	public function testObjectMissingTrailingComma() {
		assertMsg(configuredCheck(), OBJECT_MISSING, OBJECT_MSG);
	}

	@Test
	public function testObjectWithTrailingComma() {
		assertNoMsg(configuredCheck(), OBJECT_OK);
	}

	@Test
	public function testArrayMissingTrailingComma() {
		assertMsg(configuredCheck(), ARRAY_MISSING, ARRAY_MSG);
	}

	@Test
	public function testArrayWithTrailingComma() {
		assertNoMsg(configuredCheck(), ARRAY_OK);
	}

	@Test
	public function testSingleLineObjectIgnored() {
		assertNoMsg(configuredCheck(), OBJECT_SINGLE_LINE);
	}

	@Test
	public function testTrailingCommentWithComma() {
		assertNoMsg(configuredCheck(), OBJECT_WITH_COMMENT_AND_COMMA);
	}

	@Test
	public function testTrailingCommentWithoutComma() {
		assertMsg(configuredCheck(), OBJECT_WITH_COMMENT_NO_COMMA, OBJECT_MSG);
	}
}

enum abstract TrailingCommaCheckTests(String) to String {
	var OBJECT_MISSING = "
	abstractAndClass Test {
		function make() {
			final value = {
				a: 1,
				b: 2
			};
			return value;
		}
	}";

	var OBJECT_OK = "
	abstractAndClass Test {
		function make() {
			final value = {
				a: 1,
				b: 2,
			};
			return value;
		}
	}";

	var ARRAY_MISSING = "
	abstractAndClass Test {
		function make() {
			final value = [
				1,
				2
			];
			return value;
		}
	}";

	var ARRAY_OK = "
	abstractAndClass Test {
		function make() {
			final value = [
				1,
				2,
			];
			return value;
		}
	}";

	var OBJECT_SINGLE_LINE = "
	abstractAndClass Test {
		function make() {
			final value = {a: 1, b: 2};
			return value;
		}
	}";

	var OBJECT_WITH_COMMENT_AND_COMMA = "
	abstractAndClass Test {
		function make() {
			final value = {
				a: 1,
				b: 2, // trailing item
			};
			return value;
		}
	}";

	var OBJECT_WITH_COMMENT_NO_COMMA = "
	abstractAndClass Test {
		function make() {
			final value = {
				a: 1,
				b: 2 // trailing item
			};
			return value;
		}
	}";
}
