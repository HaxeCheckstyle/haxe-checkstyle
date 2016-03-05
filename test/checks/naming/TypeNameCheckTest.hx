package checks.naming;

import checkstyle.checks.naming.TypeNameCheck;

// TODO abstract tests
class TypeNameCheckTest extends CheckTestCase {

	static inline var FORMAT_CLASS:String = "^C[A-Z][a-z]*$";

	public function testCorrectNaming() {
		var check = new TypeNameCheck ();
		assertMsg(check, TypeNameTests.TEST, '');
		assertMsg(check, TypeNameTests.TEST4, '');
	}

	public function testIncorrectNaming() {
		var check = new TypeNameCheck ();
		assertMsg(check, TypeNameTests.TEST6, 'Invalid class signature: Test_ (name should be ~/^[A-Z]+[a-zA-Z0-9]*$/)');
	}

	public function testFormat() {
		var check = new TypeNameCheck ();
		check.format = FORMAT_CLASS;

		assertMsg(check, TypeNameTests.TEST, 'Invalid typedef signature: Test3 (name should be ~/^C[A-Z][a-z]*$/)');
		assertMsg(check, TypeNameTests.TEST1, '');
		assertMsg(check, TypeNameTests.TEST2, 'Invalid interface signature: Test (name should be ~/^C[A-Z][a-z]*$/)');
		assertMsg(check, TypeNameTests.TEST3, 'Invalid typedef signature: TTest (name should be ~/^C[A-Z][a-z]*$/)');
		assertMsg(check, TypeNameTests.TEST4, '');
		assertMsg(check, TypeNameTests.TEST5, 'Invalid enum signature: EnumTest (name should be ~/^C[A-Z][a-z]*$/)');
	}

	public function testIgnoreExtern() {
		var check = new TypeNameCheck ();
		check.ignoreExtern = false;

		assertMsg(check, TypeNameTests.TEST, '');
		assertMsg(check, TypeNameTests.TEST4, '');

		check.format = FORMAT_CLASS;
		assertMsg(check, TypeNameTests.TEST4, 'Invalid class signature: TEST1 (name should be ~/^C[A-Z][a-z]*$/)');
	}

	public function testTokenCLASS() {
		var check = new TypeNameCheck ();
		check.tokens = [TypeNameCheck.CLAZZ];
		check.format = FORMAT_CLASS;

		assertMsg(check, TypeNameTests.TEST, 'Invalid class signature: Test (name should be ~/^C[A-Z][a-z]*$/)');
		assertMsg(check, TypeNameTests.TEST1, '');
		assertMsg(check, TypeNameTests.TEST2, '');
		assertMsg(check, TypeNameTests.TEST3, '');
		assertMsg(check, TypeNameTests.TEST4, '');
		assertMsg(check, TypeNameTests.TEST5, '');
	}

	public function testTokenINTERFACE() {
		var check = new TypeNameCheck ();
		check.tokens = [TypeNameCheck.INTERFACE];
		check.format = "^I[A-Z][a-z]*$";

		assertMsg(check, TypeNameTests.TEST, '');
		assertMsg(check, TypeNameTests.TEST1, '');
		assertMsg(check, TypeNameTests.TEST2, 'Invalid interface signature: Test (name should be ~/^I[A-Z][a-z]*$/)');
		assertMsg(check, TypeNameTests.TEST3, '');
		assertMsg(check, TypeNameTests.TEST4, '');
		assertMsg(check, TypeNameTests.TEST5, '');
	}

	public function testTokenENUM() {
		var check = new TypeNameCheck ();
		check.tokens = [TypeNameCheck.ENUM];
		check.format = "^Enum[A-Z][a-z]*$";

		assertMsg(check, TypeNameTests.TEST, 'Invalid enum signature: Test2 (name should be ~/^Enum[A-Z][a-z]*$/)');
		assertMsg(check, TypeNameTests.TEST1, '');
		assertMsg(check, TypeNameTests.TEST2, '');
		assertMsg(check, TypeNameTests.TEST3, '');
		assertMsg(check, TypeNameTests.TEST4, '');
		assertMsg(check, TypeNameTests.TEST5, '');
	}

	public function testTokenTYPEDEF() {
		var check = new TypeNameCheck ();
		check.tokens = [TypeNameCheck.TYPEDEF];
		check.format = "^T[A-Z][a-z]*$";

		assertMsg(check, TypeNameTests.TEST, 'Invalid typedef signature: Test3 (name should be ~/^T[A-Z][a-z]*$/)');
		assertMsg(check, TypeNameTests.TEST1, '');
		assertMsg(check, TypeNameTests.TEST2, '');
		assertMsg(check, TypeNameTests.TEST3, '');
		assertMsg(check, TypeNameTests.TEST4, '');
		assertMsg(check, TypeNameTests.TEST5, '');
	}
}

class TypeNameTests {
	public static inline var TEST:String = "
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

	public static inline var TEST1:String = "
	class CTest {
	}";

	public static inline var TEST2:String = "
	interface Test {
	}";

	public static inline var TEST3:String =
	"typedef TTest = {
		var Count:Int;
	}";

	public static inline var TEST4:String =
	"extern class TEST1 {
		var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";

	public static inline var TEST5:String =
	"enum EnumTest {
		VALUE;
	}";

	public static inline var TEST6:String = "
	class Test_ {
	}";
}