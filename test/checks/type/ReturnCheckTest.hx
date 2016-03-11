package checks.type;

import checkstyle.checks.type.ReturnCheck;

class ReturnCheckTest extends CheckTestCase<ReturnCheckTests> {

	static inline var MSG_VOID_RETURN:String = 'Void return should not explicitly be specified for function test';
	static inline var MSG_NOT_TEST1_RETURN:String = 'Return type not specified for function: test1';
	static inline var MSG_NOT_TEST2_RETURN:String = 'Return type not specified for function: test2';
	static inline var MSG_NO_ANON_RETURN:String = 'Return type not specified for anonymous function';

	public function testVoid() {
		assertMsg(new ReturnCheck(), TEST1, MSG_VOID_RETURN);
	}

	public function testNoReturnType() {
		var check = new ReturnCheck();
		assertMsg(check, TEST2, MSG_NOT_TEST1_RETURN);
		assertMsg(check, TEST2A, MSG_NOT_TEST1_RETURN);
		assertMsg(check, TEST2B, MSG_NOT_TEST1_RETURN);
		assertMsg(check, TEST_FOR, MSG_NOT_TEST1_RETURN);
		assertMsg(check, TEST_WHILE, MSG_NOT_TEST1_RETURN);
		assertMsg(check, TEST5, MSG_NO_ANON_RETURN);
	}

	public function testEmptyReturnType() {
		assertNoMsg(new ReturnCheck(), TEST3);
	}

	public function testEnforceReturnType() {
		var check = new ReturnCheck();
		check.enforceReturnType = true;
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST4);
	}

	public function testEnforceReturnTypeMissing() {
		var check = new ReturnCheck();
		check.enforceReturnType = true;

		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, MSG_NOT_TEST1_RETURN);
		assertMsg(check, TEST3, MSG_NOT_TEST2_RETURN);
	}

	public function testReturnTypeAllowEmptyReturnFalse() {
		var check = new ReturnCheck();
		check.allowEmptyReturn = false;

		assertMsg(check, TEST3, MSG_NOT_TEST2_RETURN);
	}

	public function testReturnTypeAllowEmptyReturnTrue() {
		var check = new ReturnCheck();
		check.allowEmptyReturn = true;

		assertNoMsg(check, TEST3);
		assertMsg(check, TEST2, MSG_NOT_TEST1_RETURN);
	}

	public function testExternVoid() {
		var check = new ReturnCheck();
		assertNoMsg(check, TEST6);
	}
}

@:enum
abstract ReturnCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		public function test():Void {}
	}";

	var TEST2 =
	"abstractAndClass Test {
		public function test1() {
			if (true) {
				return 0;
			}
		}
	}";

	var TEST2A =
	"abstractAndClass Test {
		public function test1() {
			switch (true) {
				case true:
					return 0;
			}
		}
	}";

	var TEST2B =
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

	var TEST3 =
	"abstractAndClass Test {
		public function test2() {
			var x = 1;
			return;
		}
	}";

	var TEST4 =
	"abstractAndClass Test {
		public function test3():Void {
			return;
		}
	}";

	var TEST5 =
	"abstractAndClass Test {
		public function test4() {
			var x = function(i){
				return i * i;
			}
			return;
		}
	}";

	var TEST6 = "
	extern class Test {
		function test4():Void;
	}";

	var TEST_FOR =
	"abstractAndClass Test {
		public function test1() {
			for (i in 0 ... 10) {
				return 5;
			}
		}
	}";

	var TEST_WHILE =
	"abstractAndClass Test {
		public function test1() {
			while (true) {
				return 5;
			}
		}
	}";
}