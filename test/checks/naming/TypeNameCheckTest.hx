package checks.naming;

import checkstyle.checks.naming.TypeNameCheck;

class TypeNameCheckTest extends CheckTestCase<TypeNameCheckTests> {

	static inline var FORMAT_CLASS:String = "^C[A-Z][a-z]*$";

	public function testCorrectNaming() {
		var check = new TypeNameCheck ();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST4);
	}

	public function testIncorrectNaming() {
		var check = new TypeNameCheck ();
		assertMsg(check, TEST6, 'Invalid class signature: Test_ (name should be ~/^[A-Z]+[a-zA-Z0-9]*$/)');
	}

	public function testFormat() {
		var check = new TypeNameCheck ();
		check.format = FORMAT_CLASS;

		assertMsg(check, TEST, 'Invalid typedef signature: Test3 (name should be ~/^C[A-Z][a-z]*$/)');
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid interface signature: Test (name should be ~/^C[A-Z][a-z]*$/)');
		assertMsg(check, TEST3, 'Invalid typedef signature: TTest (name should be ~/^C[A-Z][a-z]*$/)');
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'Invalid enum signature: EnumTest (name should be ~/^C[A-Z][a-z]*$/)');
	}

	public function testIgnoreExtern() {
		var check = new TypeNameCheck ();
		check.ignoreExtern = false;

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST4);

		check.format = FORMAT_CLASS;
		assertMsg(check, TEST4, 'Invalid class signature: TEST1 (name should be ~/^C[A-Z][a-z]*$/)');
	}

	public function testTokenCLASS() {
		var check = new TypeNameCheck ();
		check.tokens = [CLASS];
		check.format = FORMAT_CLASS;

		assertMsg(check, TEST, 'Invalid class signature: Test (name should be ~/^C[A-Z][a-z]*$/)');
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	public function testTokenINTERFACE() {
		var check = new TypeNameCheck ();
		check.tokens = [INTERFACE];
		check.format = "^I[A-Z][a-z]*$";

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid interface signature: Test (name should be ~/^I[A-Z][a-z]*$/)');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	public function testTokenENUM() {
		var check = new TypeNameCheck ();
		check.tokens = [ENUM];
		check.format = "^Enum[A-Z][a-z]*$";

		assertMsg(check, TEST, 'Invalid enum signature: Test2 (name should be ~/^Enum[A-Z][a-z]*$/)');
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	public function testTokenTYPEDEF() {
		var check = new TypeNameCheck ();
		check.tokens = [TYPEDEF];
		check.format = "^T[A-Z][a-z]*$";

		assertMsg(check, TEST, 'Invalid typedef signature: Test3 (name should be ~/^T[A-Z][a-z]*$/)');
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}
}

@:enum
abstract TypeNameCheckTests(String) to String {
	var TEST = "
	class Test {
		public var a:Int;
		private var b:Int;
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		var count5:Int = 1;
	}

	interface ITest {
	}

	enum Test2 {
		count;
		a;
	}

	typedef Test3 = {
		var count1:Int;
		var count2:String;
	}";

	var TEST1 = "
	abstractAndClass CTest {
	}";

	var TEST2 = "
	interface Test {
	}";

	var TEST3 =
	"typedef TTest = {
		var Count:Int;
	}";

	var TEST4 =
	"extern class TEST1 {
		var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";

	var TEST5 =
	"enum EnumTest {
		VALUE;
	}";

	var TEST6 = "
	class Test_ {
	}";
}