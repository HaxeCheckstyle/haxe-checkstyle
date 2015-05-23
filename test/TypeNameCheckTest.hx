package ;

import checkstyle.checks.TypeNameCheck;

// TODO abstract tests
class TypeNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var msg = checkMessage (TypeNameTests.TEST, new TypeNameCheck ());
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST4, new TypeNameCheck ());
		assertEquals ('', msg);
	}

	public function testFormat() {
		var check = new TypeNameCheck ();
		check.format = "^C[A-Z][a-z]*$";

		var msg = checkMessage (TypeNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST, check);
		assertEquals ('Invalid typedef signature: Test3 (name should be ~/^C[A-Z][a-z]*$/)', msg);

		msg = checkMessage (TypeNameTests.TEST2, check);
		assertEquals ('Invalid interface signature: Test (name should be ~/^C[A-Z][a-z]*$/)', msg);

		msg = checkMessage (TypeNameTests.TEST3, check);
		assertEquals ('Invalid typedef signature: TTest (name should be ~/^C[A-Z][a-z]*$/)', msg);

		msg = checkMessage (TypeNameTests.TEST5, check);
		assertEquals ('Invalid enum signature: EnumTest (name should be ~/^C[A-Z][a-z]*$/)', msg);
	}

	public function testIgnoreExtern() {
		var check = new TypeNameCheck ();
		check.ignoreExtern = false;

		var msg = checkMessage (TypeNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST4, new TypeNameCheck ());
		assertEquals ('', msg);

		check.format = "^C[A-Z][a-z]*$";
		msg = checkMessage (TypeNameTests.TEST4, new TypeNameCheck ());
		assertEquals ('Invalid class signature: TEST1 (name should be ~/^C[A-Z][a-z]*$/)', msg);
	}

	public function testTokenCLASS() {
		var check = new TypeNameCheck ();
		check.tokens = [ "CLASS" ];
		check.format = "^C[A-Z][a-z]*$";

		var msg = checkMessage (TypeNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST2, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST3, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST, new TypeNameCheck ());
		assertEquals ('Invalid class signature: Test (name should be ~/^C[A-Z][a-z]*$/)', msg);
	}

	public function testTokenINTERFACE() {
		var check = new TypeNameCheck ();
		check.tokens = [ "INTERFACE" ];
		check.format = "^I[A-Z][a-z]*$";

		var msg = checkMessage (TypeNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST3, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST2, new TypeNameCheck ());
		assertEquals ('Invalid interface signature: Test (name should be ~/^I[A-Z][a-z]*$/)', msg);
	}

	public function testTokenENUM() {
		var check = new TypeNameCheck ();
		check.tokens = [ "ENUM" ];
		check.format = "^Enum[A-Z][a-z]*$";

		var msg = checkMessage (TypeNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST3, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST, new TypeNameCheck ());
		assertEquals ('Invalid enum signature: Test2 (name should be ~/^Enum[A-Z][a-z]*$/)', msg);
	}

	public function testTokenTYPEDEF() {
		var check = new TypeNameCheck ();
		check.tokens = [ "TYPEDEF" ];
		check.format = "^T[A-Z][a-z]*$";

		var msg = checkMessage (TypeNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST2, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST3, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (TypeNameTests.TEST, new TypeNameCheck ());
		assertEquals ('Invalid typedef signature: Test3 (name should be ~/^T[A-Z][a-z]*$/)', msg);
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
}
