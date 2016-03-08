package checks.literal;

import checkstyle.checks.literal.MultipleStringLiteralsCheck;

class MultipleStringLiteralsCheckTest extends CheckTestCase {

	public function testAllowedMultipleStringLiterals() {
		var check = new MultipleStringLiteralsCheck();
		assertNoMsg(check, MultipleStringLiteralsCheckTests.LESS_THAN_THREE);
		assertNoMsg(check, MultipleStringLiteralsCheckTests.CONSTANT_NOT_COUNTED);
		assertNoMsg(check, MultipleStringLiteralsCheckTests.SINGLE_CHARS);
		assertNoMsg(check, MultipleStringLiteralsCheckTests.THREE_SPACE);
		assertNoMsg(check, MultipleStringLiteralsCheckTests.OBJECT_FIELD_KEYS_ISSUE_116);
	}

	public function testMultipleStringLiterals() {
		var check = new MultipleStringLiteralsCheck();
		assertMsg(check, MultipleStringLiteralsCheckTests.THREE_XML, 'Multiple string literal "xml" detected - consider using a constant');
		assertMsg(check, MultipleStringLiteralsCheckTests.THREE_XML_SWITCH, 'Multiple string literal "xml" detected - consider using a constant');
		assertMsg(check, MultipleStringLiteralsCheckTests.OBJECT_FIELD_VALUES_ISSUE_116, 'Multiple string literal "duplicate" detected - consider using a constant');
	}

	public function testIgnoreRegEx() {
		var check = new MultipleStringLiteralsCheck();
		check.ignore = "^(\\s+|xml)$";
		assertNoMsg(check, MultipleStringLiteralsCheckTests.THREE_XML);
		assertNoMsg(check, MultipleStringLiteralsCheckTests.THREE_XML_SWITCH);
	}
}

class MultipleStringLiteralsCheckTests {
	public static inline var LESS_THAN_THREE:String = "
	class Test {
		static var a:String = 'check';
		public function new(f:String = 'test') {
			a = 'xml';
			b = 'xml';
			c = 'test';
		}
	}";

	public static inline var CONSTANT_NOT_COUNTED:String = "
	class Test {
		static var a:String = 'xml';
		public function new(f:String = 'test') {
			a = 'xml';
			b = 'xml';
		}
	}";

	public static inline var THREE_XML:String = "
	class Test {
		var a:String = 'xml';
		public function new(f:String = 'xml') {
			a = 'xml';
		}
	}";

	public static inline var THREE_SPACE:String = "
	class Test {
		var a:String = '   ';
		public function new(f:String = '   ') {
			a = '   ';
		}
	}";

	public static inline var THREE_XML_SWITCH:String = "
	class Test {
		var a:String = 'xml';
		public function new(f:String = 'xml') {
			switch (f) {
				case 'xml':
				default: return;
			}
		}
	}";

	public static inline var SINGLE_CHARS:String = "
	class Test {
		public function new() {
			a = 'a' + 'a' + 'a' + 'a' + 'a';
			b = 'b' + 'b' + 'a' + 'b' + 'b';
		}
	}";

	public static inline var OBJECT_FIELD_KEYS_ISSUE_116:String = "
	class Test {
		function foo() {
			var array = [
				{ 'field': 1 },
				{ 'field': 2 },
				{ 'field': 3 },
				{ 'field': 4 },
			];
			var array = [
				{ 'field1': 1, 'field2': 2 },
				{ 'field1': 3, 'field2': 4 },
				{ 'field1': 5, 'field2': 6 }
			];
		}
	}";

	public static inline var OBJECT_FIELD_VALUES_ISSUE_116:String = "
	class Test {
		function foo() {
			var array = [
				{ 'field': 'duplicate' },
				{ 'field': 'duplicate' },
				{ 'field': 'duplicate' },
				{ 'field': 'duplicate' },
			];
		}
	}";
}