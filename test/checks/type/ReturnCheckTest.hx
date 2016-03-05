package checks.type;

import checkstyle.checks.type.ReturnCheck;

class ReturnCheckTest extends CheckTestCase {

	static inline var MSG_VOID_RETURN:String = 'No need to return Void, Default function return value type is Void: test';
	static inline var MSG_NOT_TEST1_RETURN:String = 'Return type not specified for function: test1';
	static inline var MSG_NOT_TEST2_RETURN:String = 'Return type not specified for function: test2';
	static inline var MSG_NO_ANON_RETURN:String = 'Return type not specified for anonymous function';

	public function testVoid() {
		assertMsg(new ReturnCheck(), ReturnTests.TEST1, MSG_VOID_RETURN);
	}

	public function testNoReturnType() {
		assertMsg(new ReturnCheck(), ReturnTests.TEST2, MSG_NOT_TEST1_RETURN);
		assertMsg(new ReturnCheck(), ReturnTests.TEST2A, MSG_NOT_TEST1_RETURN);
		assertMsg(new ReturnCheck(), ReturnTests.TEST2B, MSG_NOT_TEST1_RETURN);
		assertMsg(new ReturnCheck(), ReturnTests.TEST5, MSG_NO_ANON_RETURN);
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
		assertMsg(check, ReturnTests.TEST2, MSG_NOT_TEST1_RETURN);
		assertMsg(check, ReturnTests.TEST3, MSG_NOT_TEST2_RETURN);
	}

	public function testReturnTypeAllowEmptyReturnFalse() {
		var check = new ReturnCheck();
		check.allowEmptyReturn = false;

		assertMsg(check, ReturnTests.TEST3, MSG_NOT_TEST2_RETURN);
	}

	public function testReturnTypeAllowEmptyReturnTrue() {
		var check = new ReturnCheck();
		check.allowEmptyReturn = true;

		assertMsg(check, ReturnTests.TEST3, '');
		assertMsg(check, ReturnTests.TEST2, MSG_NOT_TEST1_RETURN);
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

	public static inline var TEST2A:String =
	"abstractAndClass Test {
		public function test1() {
			switch (true) {
				case true:
					return 0;
			}
		}
	}";

	public static inline var TEST2B:String =
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