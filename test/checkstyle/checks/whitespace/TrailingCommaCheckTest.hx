package checkstyle.checks.whitespace;

class TrailingCommaCheckTest extends CheckTestCase<TrailingCommaCheckTests> {
	static inline var OBJECT_MSG:String = "Missing trailing comma in multiline object literal";
	static inline var ARRAY_MSG:String = "Missing trailing comma in multiline array literal";

	@Test
	public function testObjectMissingTrailingComma() {
		assertMsg(new TrailingCommaCheck(), OBJECT_MISSING, OBJECT_MSG);
	}

	@Test
	public function testObjectWithTrailingComma() {
		assertNoMsg(new TrailingCommaCheck(), OBJECT_OK);
	}

	@Test
	public function testArrayMissingTrailingComma() {
		assertMsg(new TrailingCommaCheck(), ARRAY_MISSING, ARRAY_MSG);
	}

	@Test
	public function testArrayWithTrailingComma() {
		assertNoMsg(new TrailingCommaCheck(), ARRAY_OK);
	}

	@Test
	public function testSingleLineObjectIgnored() {
		assertNoMsg(new TrailingCommaCheck(), OBJECT_SINGLE_LINE);
	}

	@Test
	public function testTrailingCommentWithComma() {
		assertNoMsg(new TrailingCommaCheck(), OBJECT_WITH_COMMENT_AND_COMMA);
	}

	@Test
	public function testTrailingCommentWithoutComma() {
		assertMsg(new TrailingCommaCheck(), OBJECT_WITH_COMMENT_NO_COMMA, OBJECT_MSG);
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
