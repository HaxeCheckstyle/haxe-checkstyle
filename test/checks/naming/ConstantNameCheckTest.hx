package checks.naming;

import checkstyle.checks.naming.ConstantNameCheck;

class ConstantNameCheckTest extends CheckTestCase<ConstantNameCheckTests> {

	@Test
	public function testCorrectNaming() {
		var check = new ConstantNameCheck();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST3);
	}

	@Test
	public function testWrongNaming() {
		var check = new ConstantNameCheck();
		var message = 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")';
		assertMsg(check, TEST1, message);
		assertMsg(check, TEST2, message);
	}

	@Test
	public function testIgnoreExtern() {
		var check = new ConstantNameCheck();
		check.ignoreExtern = false;

		var message = 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")';
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, message);
		assertMsg(check, TEST2, message);
		assertMsg(check, TEST3, message);
	}

	@Test
	public function testTokenINLINE() {
		var check = new ConstantNameCheck();
		check.tokens = [INLINE];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertNoMsg(check, TEST3);
	}

	@Test
	public function testTokenNOTINLINE() {
		var check = new ConstantNameCheck();
		check.tokens = [NOTINLINE];

		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, 'Invalid const signature: "Count" (name should be "~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/")');
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
	}

	@Test
	public function testFormat() {
		var check = new ConstantNameCheck();
		check.format = "^[A-Z][a-z]*$";

		assertMsg(check, TEST, 'Invalid const signature: "COUNT2" (name should be "~/^[A-Z][a-z]*$/")');
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);

		check.ignoreExtern = false;
		assertNoMsg(check, TEST3);
	}
}

@:enum
abstract ConstantNameCheckTests(String) to String {
	var TEST = "
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

	var TEST1 = "
	class Test {
		static var Count:Int = 1;
		public function test() {
		}
	}";

	var TEST2 =
	"class Test {
		static inline var Count:Int = 1;
		public function test() {
			var Count:Int;
		}
	}";

	var TEST3 =
	"extern class Test {
		static var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";
}