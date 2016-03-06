package checks.naming;

import checkstyle.checks.naming.ConstantNameCheck;

class ConstantNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new ConstantNameCheck ();
		assertNoMsg(check, ConstantNameTests.TEST);
		assertNoMsg(check, ConstantNameTests.TEST3);
	}

	public function testWrongNaming() {
		var check = new ConstantNameCheck ();
		var message = 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)';
		assertMsg(check, ConstantNameTests.TEST1, message);
		assertMsg(check, ConstantNameTests.TEST2, message);
	}

	public function testIgnoreExtern() {
		var check = new ConstantNameCheck ();
		check.ignoreExtern = false;

		var message = 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)';
		assertNoMsg(check, ConstantNameTests.TEST);
		assertMsg(check, ConstantNameTests.TEST1, message);
		assertMsg(check, ConstantNameTests.TEST2, message);
		assertMsg(check, ConstantNameTests.TEST3, message);
	}

	public function testTokenINLINE() {
		var check = new ConstantNameCheck ();
		check.tokens = [ConstantNameCheck.INLINE];

		assertNoMsg(check, ConstantNameTests.TEST);
		assertNoMsg(check, ConstantNameTests.TEST1);
		assertMsg(check, ConstantNameTests.TEST2, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
		assertNoMsg(check, ConstantNameTests.TEST3);
	}

	public function testTokenNOTINLINE() {
		var check = new ConstantNameCheck ();
		check.tokens = [ConstantNameCheck.NOTINLINE];

		assertNoMsg(check, ConstantNameTests.TEST);
		assertMsg(check, ConstantNameTests.TEST1, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
		assertNoMsg(check, ConstantNameTests.TEST2);
		assertNoMsg(check, ConstantNameTests.TEST3);
	}

	public function testFormat() {
		var check = new ConstantNameCheck ();
		check.format = "^[A-Z][a-z]*$";

		assertMsg(check, ConstantNameTests.TEST, 'Invalid const signature: COUNT2 (name should be ~/^[A-Z][a-z]*$/)');
		assertNoMsg(check, ConstantNameTests.TEST1);
		assertNoMsg(check, ConstantNameTests.TEST2);
		assertNoMsg(check, ConstantNameTests.TEST3);

		check.ignoreExtern = false;
		assertNoMsg(check, ConstantNameTests.TEST3);
	}
}

class ConstantNameTests {
	public static inline var TEST:String = "
	class Test {
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		var COUNT3:Int = 1;
		var Count4:Int = 1;
		var count5:Int = 1;
		var _count5:Int = 1;

		@SuppressWarnings('checkstyle:ConstantName')
		static inline var count6:Int = 1;
		@SuppressWarnings('checkstyle:ConstantName')
		static var count7:Int = 1;
	}";

	public static inline var TEST1:String = "
	class Test {
		static var Count:Int = 1;
		public function test() {
		}
	}";

	public static inline var TEST2:String =
	"class Test {
		static inline var Count:Int = 1;
		public function test() {
			var Count:Int;
		}
	}";

	public static inline var TEST3:String =
	"extern class Test {
		static var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";
}