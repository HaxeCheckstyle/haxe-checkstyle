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
			var f = arg-> {};
			var f = (arg) -> {};
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
}