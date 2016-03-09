package checks.literal;

import checkstyle.checks.literal.MultipleStringLiteralsCheck;

class MultipleStringLiteralsCheckTest extends CheckTestCase<MultipleStringLiteralsCheckTests> {

	public function testAllowedMultipleStringLiterals() {
		var check = new MultipleStringLiteralsCheck();
		assertNoMsg(check, LESS_THAN_THREE);
		assertNoMsg(check, CONSTANT_NOT_COUNTED);
		assertNoMsg(check, SINGLE_CHARS);
		assertNoMsg(check, THREE_SPACE);
		assertNoMsg(check, OBJECT_FIELD_KEYS_ISSUE_116);
	}

	public function testMultipleStringLiterals() {
		var check = new MultipleStringLiteralsCheck();
		assertMsg(check, THREE_XML, 'Multiple string literal "xml" detected - consider using a constant');
		assertMsg(check, THREE_XML_SWITCH, 'Multiple string literal "xml" detected - consider using a constant');
		assertMsg(check, OBJECT_FIELD_VALUES_ISSUE_116, 'Multiple string literal "duplicate" detected - consider using a constant');
	}

	public function testIgnoreRegEx() {
		var check = new MultipleStringLiteralsCheck();
		check.ignore = "^(\\s+|xml)$";
		assertNoMsg(check, THREE_XML);
		assertNoMsg(check, THREE_XML_SWITCH);
	}

	public function testStringInterpolation() {
		var check = new MultipleStringLiteralsCheck();
		check.allowDuplicates = 1;
		assertNoMsg(check, INTERPOLATION_ISSUE_109);
		assertMsg(check, NO_INTERPOLATION_ISSUE_109, 'Multiple string literal "value $$$$is i" detected - consider using a constant');
		assertMsg(check, NO_INTERPOLATION_AT_START_ISSUE_109, 'Multiple string literal "$$$$is i" detected - consider using a constant');
	}
}

@:enum
abstract MultipleStringLiteralsCheckTests(String) to String {
	var LESS_THAN_THREE = "
	class Test {
		static var a:String = 'check';
		public function new(f:String = 'test') {
			a = 'xml';
			b = 'xml';
			c = 'test';
		}
	}";

	var CONSTANT_NOT_COUNTED = "
	class Test {
		static var a:String = 'xml';
		public function new(f:String = 'test') {
			a = 'xml';
			b = 'xml';
		}
	}";

	var THREE_XML = "
	class Test {
		var a:String = 'xml';
		public function new(f:String = 'xml') {
			a = 'xml';
		}
	}";

	var THREE_SPACE = "
	class Test {
		var a:String = '   ';
		public function new(f:String = '   ') {
			a = '   ';
		}
	}";

	var THREE_XML_SWITCH = "
	class Test {
		var a:String = 'xml';
		public function new(f:String = 'xml') {
			switch (f) {
				case 'xml':
				default: return;
			}
		}
	}";

	var SINGLE_CHARS = "
	class Test {
		public function new() {
			a = 'a' + 'a' + 'a' + 'a' + 'a';
			b = 'b' + 'b' + 'a' + 'b' + 'b';
		}
	}";

	var OBJECT_FIELD_KEYS_ISSUE_116 = "
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

	var OBJECT_FIELD_VALUES_ISSUE_116 = "
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

	var INTERPOLATION_ISSUE_109 = "
	class Test {
		function foo() {
			trace('Value is $i');
			trace('Value is $i');
			trace('$value is i');
			trace('$value is i');
			trace('$value');
			trace('$value');
			trace('Value is ${i++}');
			trace('Value is ${i++}');
			trace('Value is ${i++}$$');
			trace('Value is ${i++}$$');
			trace('Value is ${i++} $i');
			trace('Value is ${i++} $i');
			trace('$value is ${i++} $i');
			trace('$value is ${i++} $i');
		}
	}";

	var NO_INTERPOLATION_ISSUE_109 = "
	class Test {
		function foo() {
			trace('value $$is i');
			trace('value $$is i');
		}
	}";

	var NO_INTERPOLATION_AT_START_ISSUE_109 = "
	class Test {
		function foo() {
			trace('$$is i');
			trace('$$is i');
		}
	}";
}