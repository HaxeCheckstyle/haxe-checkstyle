package checks.whitespace;

import checkstyle.CheckMessage.SeverityLevel;
import checkstyle.checks.whitespace.IndentationCheck;

class IndentationCheckTest extends CheckTestCase<IndentationCheckTests> {

	@Test
	public function testCorrectTabIndentation() {
		var check = new IndentationCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, CORRECT_TAB_INDENT);
		assertNoMsg(check, WRAPPED_PARAMS);
		assertMsg(check, CORRECT_SPACE_INDENT, "Indentation mismatch: expected: 1, actual: 0");
	}

	@Test
	public function testCorrectSpaceIndentation() {
		var check = new IndentationCheck();
		check.character = "  ";
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, CORRECT_SPACE_INDENT);
		assertMsg(check, CORRECT_TAB_INDENT, "Indentation mismatch: expected: 1, actual: 0");
	}

	@Test
	public function testConditional() {
		var check = new IndentationCheck();
		check.severity = SeverityLevel.INFO;

		assertMsg(check, WRONG_CONDITIONAL, "Indentation mismatch: expected: 1, actual: 0");
		check.ignoreConditionals = true;
		assertNoMsg(check, WRONG_CONDITIONAL);
		assertNoMsg(check, CORRECT_TAB_INDENT);
	}

	@Test
	public function testComments() {
		var check = new IndentationCheck();
		check.severity = SeverityLevel.INFO;
		check.ignoreComments = false;
		assertNoMsg(check, CORRECT_COMMENTS);
		assertMsg(check, CORRECT_TAB_INDENT, "Indentation mismatch: expected: 2, actual: 0");
	}

	@Test
	public function testWrap() {
		var check = new IndentationCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, WRAPPED_PARAMS);
		assertNoMsg(check, WRAPPED_STRING);
		assertMsg(check, WRONG_WRAPPED_PARAMS, "Indentation mismatch: expected: 2, actual: 1");
		check.wrapPolicy = LARGER;
		assertNoMsg(check, WRAPPED_PARAMS);
		assertNoMsg(check, WRAPPED_STRING);
		assertMsg(check, WRONG_WRAPPED_PARAMS, "Indentation mismatch: expected: 2, actual: 1");
	}
}

@:enum
abstract IndentationCheckTests(String) to String {
	var CORRECT_TAB_INDENT = "
class Test {
	static inline var INDENTATION_CHARACTER_CHECK_TEST:Int = 100;
	public function new() {}
	public function test() {
		// comment
		doSomething(); // comment
		x = [
			1,
			2,
			3
		];
/*
long comment
*/
		/*
		long comment
		*/
		#if php
		x = [{
			a:1,
			b:2,
			c:3
		}];
		#end
		if (true) doSomething();
		for (i in items)
			doSomething(i);
		for (i in items) {
			doSomething(i);
		}
		while (true)
			doSomething();
		while (true) {
			doSomething();
		}
		do
			doSomething()
		while(true);
		do {
			doSomething();
		} while(true);
		if (true)
			doSomething();

		if (false)
			doSomething();
		else
			doSomething2();
		if (false) {
			doSomething();
		}
		else {
			doSomething2();
		}
		switch (value) {
			case 1:
				doSomething();
			case 2:
				doSomething();
			default:
				doSomething();
		}
	}
}";

	var CORRECT_SPACE_INDENT = "
class Test {
  static inline var INDENTATION_CHARACTER_CHECK_TEST:Int = 100;
  public function new() {}
  public function test() {
    // comment
    doSomething();
    x = [
      1,
      2,
      3
    ];
/*
long comment
*/
    /*
    long comment
    */
    #if php
    x = [{
      a:1,
      b:2,
      c:3
    }];
    #end
  }
}";

	var WRONG_CONDITIONAL = "
class Test {
#if php
	var a:Int;
#end
	public function new() {}
}";

	var WRAPPED_PARAMS = "
class Test {
	public function new(param1:Int,
		param2:Int,
		param3:Int,
		param4:Int) {
		doSomething();
	}
	public function new(param1:Int,
						param2:Int,
						param3:Int,
						param4:Int) {
		doSomething();
	}
}";

	var WRONG_WRAPPED_PARAMS = "
class Test {
	public function new(param1:Int,
	param2:Int,
	param3:Int,
	param4:Int) {
	doSomething();
	}
}";

	var WRAPPED_STRING = "
class Test {
	public function test() {
		return '
test
test
test';
	}
}";

	var CORRECT_COMMENTS = "
class Test {
	// comment
	public function new() {
		/* comment
		comment
		comment
		*/
		// comment
		doSomething(); // comment
		switch (value) {
			// comment
			case 1:
				doSomething();
			default:
		}
	}
}";
}