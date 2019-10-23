package checkstyle.checks.coding;

class ArrowFunctionCheckTest extends CheckTestCase<ArrowFunctionCheckTests> {
	@Test
	public function testArrowFunction() {
		#if haxe4
		var check = new ArrowFunctionCheck();
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);

		assertMsg(check, ARROW_FUNCTION_WITH_CURLY, "Arrow function should not have curlies");
		assertMsg(check, ARROW_FUNCTION_WITH_RETURN, "Arrow function should not have explicit returns");
		assertMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION, "Arrow function should not include nested functions");
		assertMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT, "Arrow function should not use parens for single argument invocation");
		#end
	}

	@Test
	public function testAllowReturn() {
		#if haxe4
		var check = new ArrowFunctionCheck();
		check.allowReturn = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertNoMsg(check, ARROW_FUNCTION_WITH_RETURN);

		assertMsg(check, ARROW_FUNCTION_WITH_CURLY, "Arrow function should not have curlies");
		assertMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION, "Arrow function should not include nested functions");
		assertMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT, "Arrow function should not use parens for single argument invocation");
		#end
	}

	@Test
	public function testAllowFunction() {
		#if haxe4
		var check = new ArrowFunctionCheck();
		check.allowFunction = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertNoMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION);

		assertMsg(check, ARROW_FUNCTION_WITH_RETURN, "Arrow function should not have explicit returns");
		assertMsg(check, ARROW_FUNCTION_WITH_CURLY, "Arrow function should not have curlies");
		assertMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT, "Arrow function should not use parens for single argument invocation");
		#end
	}

	@Test
	public function testAllowCurly() {
		#if haxe4
		var check = new ArrowFunctionCheck();
		check.allowCurlyBody = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertNoMsg(check, ARROW_FUNCTION_WITH_CURLY);

		assertMsg(check, ARROW_FUNCTION_WITH_RETURN, "Arrow function should not have explicit returns");
		assertMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION, "Arrow function should not include nested functions");
		assertMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT, "Arrow function should not use parens for single argument invocation");
		#end
	}

	@Test
	public function testAllowSingleArg() {
		#if haxe4
		var check = new ArrowFunctionCheck();
		check.allowSingleArgParens = true;
		assertNoMsg(check, CORRECT_ARROW_FUNCTION);
		assertNoMsg(check, ARROW_FUNCTION_WITH_SINGLE_ARGUMENT);

		assertMsg(check, ARROW_FUNCTION_WITH_RETURN, "Arrow function should not have explicit returns");
		assertMsg(check, ARROW_FUNCTION_WITH_CURLY, "Arrow function should not have curlies");
		assertMsg(check, ARROW_FUNCTION_WITH_NESTED_FUNCTION, "Arrow function should not include nested functions");
		#end
	}
}

@:enum
abstract ArrowFunctionCheckTests(String) to String {
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
}