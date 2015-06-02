package ;

import checkstyle.checks.ReturnCheck;

class ReturnCheckTest extends CheckTestCase {

	public function testVoid() {
		var msg = checkMessage(ReturnTests.TEST1, new ReturnCheck());
		assertEquals('No need to return Void, Default function return value type is Void: test', msg);
	}

	public function testNoReturnType() {
		var msg = checkMessage(ReturnTests.TEST2, new ReturnCheck());
		assertEquals('Return type not specified for function: test1', msg);

		msg = checkMessage(ReturnTests.TEST2a, new ReturnCheck());
		assertEquals('Return type not specified for function: test1', msg);

		msg = checkMessage(ReturnTests.TEST2b, new ReturnCheck());
		assertEquals('Return type not specified for function: test1', msg);

		msg = checkMessage(ReturnTests.TEST5, new ReturnCheck());
		assertEquals('Return type not specified for anonymous function', msg);
	}

	public function testEmptyReturnType() {
		var msg = checkMessage(ReturnTests.TEST3, new ReturnCheck());
		assertEquals('', msg);
	}

	public function testEnforceReturnType() {
		var check = new ReturnCheck ();
		check.enforceReturnType = true;
		var msg = checkMessage(ReturnTests.TEST1, check);
		assertEquals('', msg);
		msg = checkMessage(ReturnTests.TEST4, check);
		assertEquals('', msg);
	}

	public function testEnforceReturnTypeMissing() {
		var check = new ReturnCheck ();
		check.enforceReturnType = true;
		var msg = checkMessage(ReturnTests.TEST1, check);
		assertEquals('', msg);

		msg = checkMessage(ReturnTests.TEST2, check);
		assertEquals('Return type not specified for function: test1', msg);

		msg = checkMessage(ReturnTests.TEST3, check);
		assertEquals('Return type not specified for function: test2', msg);
	}

	public function testReturnTypeAllowEmptyReturnFalse() {
		var check = new ReturnCheck();
		check.allowEmptyReturn = false;

		var msg = checkMessage(ReturnTests.TEST3, check);
		assertEquals('Return type not specified for function: test2', msg);
	}

	public function testReturnTypeAllowEmptyReturnTrue() {
		var check = new ReturnCheck();
		check.allowEmptyReturn = true;

		var msg = checkMessage(ReturnTests.TEST3, check);
		assertEquals('', msg);

		msg = checkMessage(ReturnTests.TEST2, check);
		assertEquals('Return type not specified for function: test1', msg);
	}
}

class ReturnTests {
	public static inline var TEST1:String = "
	class Test {
		public function test():Void {}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function test1() {
			if (true) {
				return 0;
			}
		}
	}";

	public static inline var TEST2a:String =
	"class Test {
		public function test1() {
			switch (true) {
				case true:
					return 0;
			}
		}
	}";

	public static inline var TEST2b:String =
	"class Test {
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
	"class Test {
		public function test2() {
			var x = 1;
			return;
		}
	}";

	public static inline var TEST4:String =
	"class Test {
		public function test3():Void {
			return;
		}
	}";

	public static inline var TEST5:String =
	"class Test {
		public function test4() {
			var x = function(i){
				return i * i;
			}
			return;
		}
	}";
}