package checkstyle.checks.literal;

class StringLiteralCheckTest extends CheckTestCase<StringLiteralCheckTests> {
	@Test
	public function testOnlySingleQuote() {
		var check = new StringLiteralCheck();
		check.policy = ONLY_SINGLE;
		check.allowException = false;
		assertNoMsg(check, SINGLE_QUOTE);
		assertNoMsg(check, INTERPOLATION);
		assertNoMsg(check, NO_INTERPOLATION);
		assertMessages(check, DOUBLE_QUOTE, [
			'String "check" uses double quotes instead of single quotes',
			'String "test" uses double quotes instead of single quotes',
			'String "xml" uses double quotes instead of single quotes',
			'String "test" uses double quotes instead of single quotes'
		]);
		assertMsg(check, SINGLE_QUOTE_WITH_EXCEPTION, "String \"test 'xml' \" uses double quotes instead of single quotes");
	}

	@Test
	public function testSingleQuoteWithException() {
		var check = new StringLiteralCheck();
		check.policy = ONLY_SINGLE;
		check.allowException = true;
		assertNoMsg(check, SINGLE_QUOTE);
		assertNoMsg(check, INTERPOLATION);
		assertNoMsg(check, NO_INTERPOLATION);
		assertNoMsg(check, SINGLE_QUOTE_WITH_EXCEPTION);
		assertMessages(check, DOUBLE_QUOTE, [
			'String "check" uses double quotes instead of single quotes',
			'String "test" uses double quotes instead of single quotes',
			'String "xml" uses double quotes instead of single quotes',
			'String "test" uses double quotes instead of single quotes'
		]);
	}

	@Test
	public function testOnlyDoubleQuote() {
		var check = new StringLiteralCheck();
		check.policy = ONLY_DOUBLE;
		check.allowException = false;
		assertNoMsg(check, DOUBLE_QUOTE);
		assertMessages(check, SINGLE_QUOTE, [
			'String "check" uses single quotes instead of double quotes',
			'String "test" uses single quotes instead of double quotes',
			'String "xml" uses single quotes instead of double quotes',
			'String "test" uses single quotes instead of double quotes'
		]);
		assertMessages(check, INTERPOLATION, [
			'String "Value is $$i" uses single quotes instead of double quotes',
			'String "Value is $$i" uses single quotes instead of double quotes',
			'String "$$value is i" uses single quotes instead of double quotes',
			'String "$$value is i" uses single quotes instead of double quotes',
			'String "$$value" uses single quotes instead of double quotes',
			'String "$$value" uses single quotes instead of double quotes',
			'String "Value is $${i++}" uses single quotes instead of double quotes',
			'String "Value is $${i++}" uses single quotes instead of double quotes',
			'String "Value is $${i++}$$" uses single quotes instead of double quotes',
			'String "Value is $${i++}$$" uses single quotes instead of double quotes',
			'String "Value is $${i++} $$i" uses single quotes instead of double quotes',
			'String "Value is $${i++} $$i" uses single quotes instead of double quotes',
			'String "$$value is $${i++} $$i" uses single quotes instead of double quotes',
			'String "$$value is $${i++} $$i" uses single quotes instead of double quotes'
		]);
		#if (haxeparser < "3.3.0")
		assertMsg(check, NO_INTERPOLATION, 'String "value $$$$is i" uses single quotes instead of double quotes');
		#end
		assertMsg(check, DOUBLE_QUOTE_WITH_EXCEPTION, 'String "test "xml" " uses single quotes instead of double quotes');
	}

	@Test
	public function testDoubleQuoteWithException() {
		var check = new StringLiteralCheck();
		check.policy = ONLY_DOUBLE;
		check.allowException = true;
		assertNoMsg(check, DOUBLE_QUOTE);
		assertNoMsg(check, DOUBLE_QUOTE_WITH_EXCEPTION);
		assertMessages(check, SINGLE_QUOTE, [
			'String "check" uses single quotes instead of double quotes',
			'String "test" uses single quotes instead of double quotes',
			'String "xml" uses single quotes instead of double quotes',
			'String "test" uses single quotes instead of double quotes'
		]);
		assertMessages(check, INTERPOLATION, [
			'String "Value is $$i" uses single quotes instead of double quotes',
			'String "Value is $$i" uses single quotes instead of double quotes',
			'String "$$value is i" uses single quotes instead of double quotes',
			'String "$$value is i" uses single quotes instead of double quotes',
			'String "$$value" uses single quotes instead of double quotes',
			'String "$$value" uses single quotes instead of double quotes',
			'String "Value is $${i++}" uses single quotes instead of double quotes',
			'String "Value is $${i++}" uses single quotes instead of double quotes',
			'String "Value is $${i++}$$" uses single quotes instead of double quotes',
			'String "Value is $${i++}$$" uses single quotes instead of double quotes',
			'String "Value is $${i++} $$i" uses single quotes instead of double quotes',
			'String "Value is $${i++} $$i" uses single quotes instead of double quotes',
			'String "$$value is $${i++} $$i" uses single quotes instead of double quotes',
			'String "$$value is $${i++} $$i" uses single quotes instead of double quotes'
		]);
		#if (haxeparser < "3.3.0")
		assertMsg(check, NO_INTERPOLATION, 'String "value $$$$is i" uses single quotes instead of double quotes');
		#end
	}

	@Test
	public function testDoubleQuoteWithInterpolation() {
		var check = new StringLiteralCheck();
		check.allowException = false;
		assertNoMsg(check, DOUBLE_QUOTE);
		assertNoMsg(check, INTERPOLATION);
		assertMessages(check, SINGLE_QUOTE, [
			'String "check" uses single quotes instead of double quotes',
			'String "test" uses single quotes instead of double quotes',
			'String "xml" uses single quotes instead of double quotes',
			'String "test" uses single quotes instead of double quotes'
		]);
		#if (haxeparser < "3.3.0")
		assertMsg(check, NO_INTERPOLATION, 'String "value $$$$is i" uses single quotes instead of double quotes');
		#end
		assertMsg(check, DOUBLE_QUOTE_WITH_EXCEPTION, 'String "test "xml" " uses single quotes instead of double quotes');
	}

	@Test
	public function testDoubleQuoteWithInterpolationAndException() {
		var check = new StringLiteralCheck();
		check.allowException = true;
		assertNoMsg(check, DOUBLE_QUOTE);
		assertNoMsg(check, INTERPOLATION);
		assertNoMsg(check, DOUBLE_QUOTE_WITH_EXCEPTION);
		assertMessages(check, SINGLE_QUOTE, [
			'String "check" uses single quotes instead of double quotes',
			'String "test" uses single quotes instead of double quotes',
			'String "xml" uses single quotes instead of double quotes',
			'String "test" uses single quotes instead of double quotes'
		]);
		#if (haxeparser < "3.3.0")
		assertMsg(check, NO_INTERPOLATION, 'String "value $$$$is i" uses single quotes instead of double quotes');
		#end
	}
}

enum abstract StringLiteralCheckTests(String) to String {
	var SINGLE_QUOTE = "
	class Test {
		static var a:String = 'check';
		public function new(f:String = 'test') {
			a = 'xml';
			c = 'test';
		}
	}";
	var SINGLE_QUOTE_WITH_EXCEPTION = "
	class Test {
		static var a:String = 'check';
		public function new(f:String = 'test') {
			a = 'xml';
			c = 'test';
			c = \"test 'xml' \";
		}
	}";
	var DOUBLE_QUOTE = '
	class Test {
		static var a:String = "check";
		public function new(f:String = "test") {
			a = "xml";
			c = "test";
		}
	}';
	var DOUBLE_QUOTE_WITH_EXCEPTION = '
	class Test {
		static var a:String = "check";
		public function new(f:String = "test") {
			a = "xml";
			c = "test";
			c = \'test "xml" \';
		}
	}';
	var INTERPOLATION = "
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
	var NO_INTERPOLATION = "
	class Test {
		function foo() {
			trace('value $$is i');
			trace('value $$is i');
		}
	}";
}