package checkstyle.checks.coding;

class ArrowFunctionCheckTest extends CheckTestCase<ArrowFunctionCheckTests> {
	@Test
	public function testArrowFunction() {
		var check = new ArrowFunctionCheck();
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);

		assertMsg(check, ARROW_FUNCTION_WITH_CURLY, "Arrow function should not have curlies");
		assertMsg(check, ARROW_FUNCTION_WITH_RETURN, "Arrow function should not have explicit returns");
		assertMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION, "Arrow function should not include nested functions");
		assertMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT, "Arrow function should not use parens for single argument invocation");
	}

	@Test
	public function testAllowReturn() {
		var check = new ArrowFunctionCheck();
		check.allowReturn = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertNoMsg(check, ARROW_FUNCTION_WITH_RETURN);

		assertMsg(check, ARROW_FUNCTION_WITH_CURLY, "Arrow function should not have curlies");
		assertMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION, "Arrow function should not include nested functions");
		assertMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT, "Arrow function should not use parens for single argument invocation");
	}

	@Test
	public function testAllowFunction() {
		var check = new ArrowFunctionCheck();
		check.allowFunction = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertNoMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION);

		assertMsg(check, ARROW_FUNCTION_WITH_RETURN, "Arrow function should not have explicit returns");
		assertMsg(check, ARROW_FUNCTION_WITH_CURLY, "Arrow function should not have curlies");
		assertMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT, "Arrow function should not use parens for single argument invocation");
	}

	@Test
	public function testAllowCurly() {
		var check = new ArrowFunctionCheck();
		check.allowCurlyBody = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertNoMsg(check, ARROW_FUNCTION_WITH_CURLY);

		assertMsg(check, ARROW_FUNCTION_WITH_RETURN, "Arrow function should not have explicit returns");
		assertMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION, "Arrow function should not include nested functions");
		assertMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT, "Arrow function should not use parens for single argument invocation");
	}

	@Test
	public function testAllowSingleArg() {
		var check = new ArrowFunctionCheck();
		check.allowSingleArgParens = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertNoMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT);

		assertMsg(check, ARROW_FUNCTION_WITH_RETURN, "Arrow function should not have explicit returns");
		assertMsg(check, ARROW_FUNCTION_WITH_CURLY, "Arrow function should not have curlies");
		assertMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION, "Arrow function should not include nested functions");
	}

	@Test
	public function testEnforceArrowForNonMemberFunctions() {
		var check = new ArrowFunctionCheck();
		check.enforceArrowForNonMemberFunctions = true;
		check.allowReturn = true;
		check.allowFunction = true;
		check.allowCurlyBody = true;
		check.allowSingleArgParens = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertMsg(check, FUNCTION_EXPRESSION, "Non-member function should use arrow syntax");
		assertMsg(check, NAMED_LOCAL_FUNCTION, "Non-member function should use arrow syntax");
	}
}

enum abstract ArrowFunctionCheckTests(String) to String {
	var CORRECT_ARROW_FUNCTION = "
	abstractAndClass Test {
		function main() {
			var f:Void->Void;
			var f:()->Void;
			var f = () ->trace('');
			var f = () -> {};
			var f = arg -> {};
			var f = (arg1:Int, arg2:String) -> {};
			fields.map(field -> field.type);
		}
	}";
	var ARROW_FUNCTION_WITH_CURLY = "
	abstractAndClass Test {
		function main() {
			var f = () -> {
				trace('');
			}
		}
	}";
	var ARROW_FUNCTION_WITH_RETURN = "
	abstractAndClass Test {
		function main() {
			fields.map(field -> return field.type);
		}
	}";
	var ARROW_FUNCTION_WITH_NESTED_FUNCTION = "
	abstractAndClass Test {
		function main() {
			fields.map(field -> call(field, function(param) { return param * 2;}));
		}
	}";
	var ARROW_FUNCTION_WITH_SINGLE_ARGUMENT = "
	abstractAndClass Test {
		var f = (arg) -> {};
	}";
	var FUNCTION_EXPRESSION = "
	abstractAndClass Test {
		function main() {
			final f = function(value:Int) {
				return value + 1;
			}
			f(1);
		}
	}";
	var NAMED_LOCAL_FUNCTION = "
	abstractAndClass Test {
		function main() {
			function helper(value:Int):Int {
				return value + 1;
			}
			helper(1);
		}
	}";
}
