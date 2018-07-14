package checks.whitespace;

import checkstyle.SeverityLevel;
import checkstyle.checks.whitespace.IndentationCheck;

class IndentationCheckTest extends CheckTestCase<IndentationCheckTests> {

	@Test
	public function testCorrectTabIndentation() {
		var check = new IndentationCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, CORRECT_TAB_INDENT);
		assertNoMsg(check, FUNCTION_BODY_NO_BRACES);
		assertMsg(check, CORRECT_SPACE_INDENT, 'Indentation mismatch: expected: "\\t"[1], actual: no indentation');
	}

	@Test
	public function testCorrectSpaceIndentation() {
		var check = new IndentationCheck();
		check.character = cast "  ";
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, CORRECT_SPACE_INDENT);
		assertMsg(check, CORRECT_TAB_INDENT, 'Indentation mismatch: expected: "  "[1], actual: no indentation');
	}

	@Test
	public function testConditional() {
		var check = new IndentationCheck();
		check.severity = SeverityLevel.INFO;

		assertMsg(check, WRONG_CONDITIONAL, 'Indentation mismatch: expected: "\\t"[1], actual: no indentation');
		check.ignoreConditionals = true;
		assertNoMsg(check, WRONG_CONDITIONAL);
		assertNoMsg(check, CORRECT_TAB_INDENT);
		check.ignoreConditionals = false;

		check.conditionalPolicy = IGNORE;
		assertNoMsg(check, WRONG_CONDITIONAL);
		assertNoMsg(check, CORRECT_TAB_INDENT);

		check.conditionalPolicy = FIXED_ZERO;
		assertNoMsg(check, WRONG_CONDITIONAL);
		assertMsg(check, CORRECT_TAB_INDENT, 'Indentation mismatch: expected: no indentation, actual: "\\t\\t\\t"[3]');

		check.conditionalPolicy = ALIGNED;
		assertMsg(check, WRONG_CONDITIONAL, 'Indentation mismatch: expected: "\\t"[1], actual: no indentation');
		assertNoMsg(check, CORRECT_TAB_INDENT);

		check.conditionalPolicy = ALIGNED_INCREASE;
		assertMsg(check, WRONG_CONDITIONAL, 'Indentation mismatch: expected: "\\t"[1], actual: no indentation');
		assertNoMsg(check, CONDITIONAL_INCREASE);
		assertMsg(check, CORRECT_TAB_INDENT, 'Indentation mismatch: expected: "\\t\\t\\t\\t\\t"[5], actual: "\\t\\t\\t\\t"[4]');
	}

	@Test
	public function testComments() {
		var check = new IndentationCheck();
		check.severity = SeverityLevel.INFO;
		check.ignoreComments = false;
		assertNoMsg(check, CORRECT_COMMENTS);
		assertMsg(check, CORRECT_TAB_INDENT, 'Indentation mismatch: expected: no indentation, actual: "\\t"[1]');
	}

	@Test
	public function testWrap() {
		var check = new IndentationCheck();
		check.severity = SeverityLevel.INFO;
		assertNoMsg(check, LARGER_WRAPPED_PARAMS);
		assertNoMsg(check, EXACT_WRAPPED_PARAMS);
		assertNoMsg(check, WRAPPED_STRING);
		assertNoMsg(check, CORRECT_PCLOSE_WRAPPING_ISSUE_450);
		assertMsg(check, NONE_WRAPPED_PARAMS, 'Indentation mismatch: expected: "\\t\\t"[2], actual: "\\t"[1]');
		check.wrapPolicy = EXACT;
		assertNoMsg(check, WRAPPED_STRING);
		assertNoMsg(check, CORRECT_PCLOSE_WRAPPING_ISSUE_450);
		assertMsg(check, LARGER_WRAPPED_PARAMS, 'Indentation mismatch: expected: "\\t\\t"[2], actual: "\\t\\t\\t\\t\\t\\t"[6]');
		assertMsg(check, NONE_WRAPPED_PARAMS, 'Indentation mismatch: expected: "\\t\\t"[2], actual: "\\t"[1]');

		check.wrapPolicy = NONE;
		assertNoMsg(check, NONE_WRAPPED_PARAMS);
		assertMsg(check, LARGER_WRAPPED_PARAMS, 'Indentation mismatch: expected: "\\t"[1], actual: "\\t\\t\\t\\t\\t\\t"[6]');
		assertMsg(check, EXACT_WRAPPED_PARAMS, 'Indentation mismatch: expected: "\\t"[1], actual: "\\t\\t"[2]');
	}
}

@:enum
abstract IndentationCheckTests(String) to String {
	var CORRECT_TAB_INDENT = "
class Test {
	static inline var INDENTATION_CHARACTER_CHECK_TEST:Int = 100;
	public var type(default, null):CheckType;
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
			#if php
			case 1:
				doSomething();
			#end
			case 2:
				doSomething();
			case 3,
				4,
				5:
				doSomething();
			case 6:
				#if php
				doSomething();
				#else
				doSomething();
				#end
				doSomething();
			#if (haxe_ver < 4.0)
			case 7:
				doSomething();
			#end
			default:
				doSomething();
		}
		doSomething({
			a: 1,
			b: 2
		});
		checkInfos[names[i]] = {
			name: names[i],
			clazz: cl,
			isAlias: i > 0,
			description: (i == 0) ? desc : desc + ' [DEPRECATED, use ' + names[0] + ' instead]'
		};
		builder()
			.create
			.something()
			.with()
			.data()
			.build()
			.run();
		builder
			.create
			.something();
	}
}
/*
	comment
*/
";

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

	var CONDITIONAL_INCREASE = "
class Test {
	#if php
		var a:Int;
	#end
	public function new() {}
}";

	var LARGER_WRAPPED_PARAMS = "
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

	var EXACT_WRAPPED_PARAMS = "
class Test {
	public function new(param1:Int,
		param2:Int,
		param3:Int,
		param4:Int) {
		doSomething();
	}
}";

	var NONE_WRAPPED_PARAMS = "
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
		 * comment
		 * comment
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
}
/*
 * test comment
 */";

	var FUNCTION_BODY_NO_BRACES = "
class Test {
	public function toString()
		return 'Test class';
}";

	var CORRECT_PCLOSE_WRAPPING_ISSUE_450 = "
class Test {
	public function new(
		param4:Int
	) {
		doSomething();
	}
}";
}