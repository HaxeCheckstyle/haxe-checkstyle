package ;

import checkstyle.checks.ReturnCheck;

class ReturnCheckTest extends CheckTestCase {

	public function testVoid() {
		var msg = checkMessage(ReturnTests.TEST1, new ReturnCheck());
		assertEquals(msg, 'No need to return Void, Default function return value type is Void: test');
	}

	public function testNoReturnType() {
		var msg = checkMessage(ReturnTests.TEST2, new ReturnCheck());
		assertEquals(msg, 'Return type not specified when returning a value for function: test1');
	}

	public function testEmptyReturnType() {
		var msg = checkMessage(ReturnTests.TEST3, new ReturnCheck());
		assertEquals(msg, '');
	}

	public function testEnforceReturnType() {
		var check = new ReturnCheck ();
		check.enforceReturnType = true;
		var msg = checkMessage(ReturnTests.TEST1, check);
		assertEquals(msg, '');
		msg = checkMessage(ReturnTests.TEST4, check);
		assertEquals(msg, '');
	}

	public function testEnforceReturnTypeMissing() {
		var check = new ReturnCheck ();
		check.enforceReturnType = true;
		var msg = checkMessage(ReturnTests.TEST1, check);
		assertEquals(msg, '');

		msg = checkMessage(ReturnTests.TEST2, check);
		assertEquals(msg, 'Return type not specified when returning a value for function: test1');

		msg = checkMessage(ReturnTests.TEST3, check);
		assertEquals(msg, 'Return type not specified for function: test2');
	}

	public function testReturnTypeAllowEmptyReturnFalse() {
		var check = new ReturnCheck ();
		check.allowEmptyReturn = false;

		var msg = checkMessage(ReturnTests.TEST2, check);
		assertEquals(msg, 'Return type not specified when returning a value for function: test1');

		msg = checkMessage(ReturnTests.TEST3, check);
		assertEquals(msg, 'Return type not specified when returning a value for function: test2');
	}

	public function testReturnTypeAllowEmptyReturnTrue() {
		var check = new ReturnCheck ();
		check.allowEmptyReturn = true;

		var msg = checkMessage(ReturnTests.TEST3, check);
		assertEquals(msg, '');

		msg = checkMessage(ReturnTests.TEST2, check);
		assertEquals(msg, 'Return type not specified when returning a value for function: test1');
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
			return 0;
		}
	}";

	public static inline var TEST3:String =
	"class Test {
		public function test2() {
			return;
		}
	}";

	public static inline var TEST4:String =
	"class Test {
		public function test3():Void {
			return;
		}
	}";
}
