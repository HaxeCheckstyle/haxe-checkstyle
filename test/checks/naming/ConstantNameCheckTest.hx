package checks.naming;

import checkstyle.checks.naming.ConstantNameCheck;

class ConstantNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new ConstantNameCheck ();
		assertMsg(check, ConstantNameTests.TEST, '');
		assertMsg(check, ConstantNameTests.TEST3, '');
	}

	public function testWrongNaming() {
		var check = new ConstantNameCheck ();
		assertMsg(check, ConstantNameTests.TEST1, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
		assertMsg(check, ConstantNameTests.TEST2, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
	}

	public function testIgnoreExtern() {
		var check = new ConstantNameCheck ();
		check.ignoreExtern = false;

		assertMsg(check, ConstantNameTests.TEST, '');
		assertMsg(check, ConstantNameTests.TEST1, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
		assertMsg(check, ConstantNameTests.TEST2, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
		assertMsg(check, ConstantNameTests.TEST3, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
	}

	public function testTokenINLINE() {
		var check = new ConstantNameCheck ();
		check.tokens = [ "INLINE" ];

		assertMsg(check, ConstantNameTests.TEST, '');
		assertMsg(check, ConstantNameTests.TEST1, '');
		assertMsg(check, ConstantNameTests.TEST2, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
		assertMsg(check, ConstantNameTests.TEST3, '');
	}

	public function testTokenNOTINLINE() {
		var check = new ConstantNameCheck ();
		check.tokens = [ "NOTINLINE" ];

		assertMsg(check, ConstantNameTests.TEST, '');
		assertMsg(check, ConstantNameTests.TEST1, 'Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)');
		assertMsg(check, ConstantNameTests.TEST2, '');
		assertMsg(check, ConstantNameTests.TEST3, '');
	}

	public function testFormat() {
		var check = new ConstantNameCheck ();
		check.format = "^[A-Z][a-z]*$";

		assertMsg(check, ConstantNameTests.TEST, 'Invalid const signature: COUNT2 (name should be ~/^[A-Z][a-z]*$/)');
		assertMsg(check, ConstantNameTests.TEST1, '');
		assertMsg(check, ConstantNameTests.TEST2, '');
		assertMsg(check, ConstantNameTests.TEST3, '');

		check.ignoreExtern = false;
		assertMsg(check, ConstantNameTests.TEST3, '');
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