package checkstyle.checks.coding;

class UnusedLocalVarCheckTest extends CheckTestCase<UnusedLocalVarCheckTests> {
	static inline var MSG_UNUSED_VAR_INDEX:String = "Unused local variable index";

	@Test
	public function testLocalVar() {
		var check = new UnusedLocalVarCheck();
		assertNoMsg(check, USED_INDEX);
		assertNoMsg(check, STRING_INTERPOLATION);
		assertNoMsg(check, MACRO);
		assertNoMsg(check, MACRO_REIFIED_VARS);
		assertNoMsg(check, ANON_STRUCT_TYPE);
		assertNoMsg(check, RETURN_ANON_STRUCT_FIELDS);
	}

	@Test
	public function testUnusedLocalVar() {
		var check = new UnusedLocalVarCheck();
		assertMsg(check, UNUSED_INDEX, MSG_UNUSED_VAR_INDEX);
		assertMsg(check, UNUSED_INDEX2, MSG_UNUSED_VAR_INDEX);
		assertMsg(check, UNUSED_FINAL, MSG_UNUSED_VAR_INDEX);
		assertMsg(check, STRING_INTERPOLATION_UNUSED, MSG_UNUSED_VAR_INDEX);
		assertMsg(check, MACRO_UNUSED, MSG_UNUSED_VAR_INDEX);
		assertMessages(check, UNUSED_IN_ARROW_FUNCTION, ["Unused local variable index", "Unused local variable index2"]);
		assertMessages(check, UNUSED_IN_CLASS_ARROW_FUNCTION, ["Unused local variable index", "Unused local variable index2"]);
	}
}

enum abstract UnusedLocalVarCheckTests(String) to String {
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
			@SuppressWarnings('checkstyle:UnusedLocalVar')
			var index:Int;
		}
		function d() {
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
	var UNUSED_FINAL = "
	abstractAndClass Test {
		public function a() {
			final index:Int;
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
	var MACRO = "
	abstractAndClass Test {
		function a() {
			var index:Int;
			var index2:Array<Int>;
			var index3:String;
			var index4:String;

			$index = 1;
			$v{index2};
			$i{index3};
			$a{index4};
		}
	}";
	var MACRO_REIFIED_VARS = "
	abstractAndClass Test {
		function a() {
			return macro class MyClass {
				var index:Int;
			};
		}
		function b() {
			call(macro {
				var index2 = 1;
			});
		}
		function c() {
			return macro function() {
				var index3 = 1;
			};
		}
	}";
	var MACRO_UNUSED = "
	abstractAndClass Test {
		function a() {
			var index:Int;

			$v{index2};
			$i{index3};
			$a{index4};
		}
	}";
	var UNUSED_IN_ARROW_FUNCTION = "
	abstractAndClass Test {
		public function a() {
			final callback = (arg:Dynamic) -> {
				var index:Int;
				final index2:Int;
			};
			callback();
		}
	}";
	var UNUSED_IN_CLASS_ARROW_FUNCTION = "
	abstractAndClass Test {
		var callback = (arg:Dynamic) -> {
			var index:Int;
			final index2:Int;
		};
		public function a() {
			callback();
		}
	}";
	var ANON_STRUCT_TYPE = "
	abstractAndClass Test {
		public function a() {
			final anon:{var index:Int;} = null;
			var anon2:{final index2:String;} = null;
			trace(anon, anon2);
		}
	}";
	var RETURN_ANON_STRUCT_FIELDS = "
	abstractAndClass Test {
		function a():{ var index:Int; final index2:Int; } {
			return null;
		}
	}";
}