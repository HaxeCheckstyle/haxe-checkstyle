package checks.type;

import checkstyle.checks.type.ReturnCheck;

class ReturnCheckTest extends CheckTestCase {

	public function testVoid() {
		assertMsg(new ReturnCheck(), ReturnTests.TEST1, 'No need to return Void, Default function return value type is Void: test');
	}

	public function testNoReturnType() {
		assertMsg(new ReturnCheck(), ReturnTests.TEST2, 'Return type not specified for function: test1');
		assertMsg(new ReturnCheck(), ReturnTests.TEST2a, 'Return type not specified for function: test1');
		assertMsg(new ReturnCheck(), ReturnTests.TEST2b, 'Return type not specified for function: test1');
		assertMsg(new ReturnCheck(), ReturnTests.TEST5, 'Return type not specified for anonymous function');
	}

	public function testEmptyReturnType() {
		assertMsg(new ReturnCheck(), ReturnTests.TEST3, '');
	}

	public function testEnforceReturnType() {
		var check = new ReturnCheck();
		check.enforceReturnType = true;
		assertMsg(check, ReturnTests.TEST1, '');
		assertMsg(check, ReturnTests.TEST4, '');
	}

	public function testEnforceReturnTypeMissing() {
		var check = new ReturnCheck();
		check.enforceReturnType = true;

		assertMsg(check, ReturnTests.TEST1, '');
		assertMsg(check, ReturnTests.TEST2, 'Return type not specified for function: test1');
		assertMsg(check, ReturnTests.TEST3, 'Return type not specified for function: test2');
	}

	public function testReturnTypeAllowEmptyReturnFalse() {
		var check = new ReturnCheck();
		check.allowEmptyReturn = false;

		assertMsg(check, ReturnTests.TEST3, 'Return type not specified for function: test2');
	}

	public function testReturnTypeAllowEmptyReturnTrue() {
		var check = new ReturnCheck();
		check.allowEmptyReturn = true;

		assertMsg(check, ReturnTests.TEST3, '');
		assertMsg(check, ReturnTests.TEST2, 'Return type not specified for function: test1');
	}

	public function testExternVoid() {
		var check = new ReturnCheck();
		assertMsg(check, ReturnTests.TEST6, '');
	}
}

class ReturnTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		public function test():Void {}
	}";

	public static inline var TEST2:String =
	"abstractAndClass Test {
		public function test1() {
			if (true) {
				return 0;
			}
		}
	}";

	public static inline var TEST2a:String =
	"abstractAndClass Test {
		public function test1() {
			switch (true) {
				case true:
					return 0;
			}
		}
	}";

	public static inline var TEST2b:String =
	"abstractAndClass Test {
		public function test1() {
			try {
				return 0;
			}
			catch (e:String) {
				return 1;
			}
		}
	}";

	public static inline var TEST3:String =
	"abstractAndClass Test {
		public function test2() {
			var x = 1;
			return;
		}
	}";

	public static inline var TEST4:String =
	"abstractAndClass Test {
		public function test3():Void {
			return;
		}
	}";

	public static inline var TEST5:String =
	"abstractAndClass Test {
		public function test4() {
			var x = function(i){
				return i * i;
			}
			return;
		}
	}";

	public static inline var TEST6:String = "
	extern class Test {
		function test4():Void;
	}";
}