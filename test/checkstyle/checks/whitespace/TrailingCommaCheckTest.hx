package checkstyle.checks.whitespace;

class TrailingCommaCheckTest extends CheckTestCase<TrailingCommaCheckTests> {
	static inline var OBJECT_MSG:String = "Missing trailing comma in multiline object literal";
	static inline var ARRAY_MSG:String = "Missing trailing comma in multiline array literal";
	static inline var COMPREHENSION_MSG:String = "Trailing comma changes semantics in array comprehension";

	function configuredCheck():TrailingCommaCheck {
		var check = new TrailingCommaCheck();
		check.enforceObjectLiterals = true;
		check.enforceArrayLiterals = true;
		return check;
	}

	function comprehensionCheck():TrailingCommaCheck {
		var check = new TrailingCommaCheck();
		check.enforceArrayComprehension = true;
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

	@Test
	public function testArrayComprehensionIgnored() {
		assertNoMsg(configuredCheck(), ARRAY_COMPREHENSION);
	}

	@Test
	public function testArrayComprehensionWhileIgnored() {
		assertNoMsg(configuredCheck(), ARRAY_COMPREHENSION_WHILE);
	}

	@Test
	public function testEnforceComprehensionWithTrailingComma() {
		assertMsg(comprehensionCheck(), ARRAY_COMPREHENSION_WITH_COMMA, COMPREHENSION_MSG);
	}

	@Test
	public function testEnforceComprehensionWithoutTrailingComma() {
		assertNoMsg(comprehensionCheck(), ARRAY_COMPREHENSION);
	}

	@Test
	public function testEnforceComprehensionDefaultIgnoresArrayLiterals() {
		assertNoMsg(comprehensionCheck(), ARRAY_MISSING);
	}

	@Test
	public function testConditionalCompilationWithTrailingComma() {
		assertNoMsg(configuredCheck(), ARRAY_WITH_CONDITIONAL_OK);
	}

	@Test
	public function testConditionalCompilationWithoutTrailingComma() {
		assertMsg(configuredCheck(), ARRAY_WITH_CONDITIONAL_MISSING, ARRAY_MSG);
	}

	@Test
	public function testMacroBlockIsNotObjectLiteral() {
		assertNoMsg(configuredCheck(), MACRO_BLOCK);
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

	var ARRAY_COMPREHENSION = "
	abstractAndClass Test {
		function make() {
			final value = [
				for (i in 0...3) {
					i;
				}
			];
			return value;
		}
	}";

	var ARRAY_COMPREHENSION_WITH_COMMA = "
	abstractAndClass Test {
		function make() {
			final value = [
				for (i in 0...3) {
					i;
				},
			];
			return value;
		}
	}";

	var ARRAY_COMPREHENSION_WHILE = "
	abstractAndClass Test {
		function make() {
			var i = 0;
			final value = [
				while (i < 3) {
					i++;
				}
			];
			return value;
		}
	}";

	var ARRAY_WITH_CONDITIONAL_OK = "
	abstractAndClass Test {
		function make() {
			final value = [
				#if !macro
				1,
				#end
			];
			return value;
		}
	}";

	var ARRAY_WITH_CONDITIONAL_MISSING = "
	abstractAndClass Test {
		function make() {
			final value = [
				#if !macro
				1
				#end
			];
			return value;
		}
	}";

	var MACRO_BLOCK = "
	class Test {
		public static macro function build() {
			return macro {
				final value = 1;
				if (value > 0) {
					trace(value);
				}
				else {
					trace(0);
				}
			};
		}
	}";
}
