package checks.coding;

import checkstyle.checks.coding.UnusedLocalVarCheck;

class UnusedLocalVarCheckTest extends CheckTestCase<UnusedLocalVarCheckTests> {

	static inline var MSG_UNUSED_VAR_INDEX:String = "Unused local variable index";

	public function testLocalVar() {
		var check = new UnusedLocalVarCheck();
		assertNoMsg(check, USED_INDEX);
		assertNoMsg(check, STRING_INTERPOLATION);
	}

	public function testUnusedLocalVar() {
		var check = new UnusedLocalVarCheck();
		assertMsg(check, UNUSED_INDEX, MSG_UNUSED_VAR_INDEX);
		assertMsg(check, UNUSED_INDEX2, MSG_UNUSED_VAR_INDEX);
		assertMsg(check, STRING_INTERPOLATION_UNUSED, MSG_UNUSED_VAR_INDEX);
	}
}

@:enum
abstract UnusedLocalVarCheckTests(String) to String {
	var USED_INDEX = "
	abstractAndClass Test {
		function a() {
			var index:Int;
			index++;
		}
		@SuppressWarnings('checkstyle:UnusedLocalVar')
		function b() {
			var index:Int;
		}

		function c() {
			var index:Int;
			call(function() {
				index++;
			});
		}
	}";

	var UNUSED_INDEX = "
	abstractAndClass Test {
		// index
		@index
		public function a(index:String) {
			var index:Int;
		}
	}";

	var UNUSED_INDEX2 = "
	abstractAndClass Test {
		public function a() {
			call(function() {
				var index:Int;
			});
		}
	}";

	var STRING_INTERPOLATION = "
	abstractAndClass Test {
		function a() {
			var index:Int;
			var index2:Array<Int>;
			var index3:String;
			var index4:String;

			trace ('$index');
			trace ('${index2.toString()}');
			trace ('${Std.parseInt(index3)}');
			trace ('${index4}');
		}
	}";

	var STRING_INTERPOLATION_UNUSED = "
	abstractAndClass Test {
		function a() {
			var index:Int;

			trace ('index');
			trace ('$index2');
			trace ('${index2.toString()}');
			trace ('${Std.parseInt(index3)}');
			trace ('${index4}');
		}
	}";
}