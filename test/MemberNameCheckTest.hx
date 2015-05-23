package ;

import checkstyle.checks.MemberNameCheck;

// TODO abstract tests
class MemberNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var msg = checkMessage (MemberNameTests.TEST, new MemberNameCheck ());
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST4, new MemberNameCheck ());
		assertEquals ('', msg);
	}

	public function testWrongNaming() {
		var msg = checkMessage (MemberNameTests.TEST1, new MemberNameCheck ());
		assertEquals ('Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST2, new MemberNameCheck ());
		assertEquals ('Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST3, new MemberNameCheck ());
		assertEquals ('Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST5, new MemberNameCheck ());
		assertEquals ('Invalid enum member signature: VALUE (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);
	}

	public function testIgnoreExtern() {
		var check = new MemberNameCheck ();
		check.ignoreExtern = false;

		var msg = checkMessage (MemberNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST1, new MemberNameCheck ());
		assertEquals ('Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST2, new MemberNameCheck ());
		assertEquals ('Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST3, new MemberNameCheck ());
		assertEquals ('Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST4, check);
		assertEquals ('Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST5, check);
		assertEquals ('Invalid enum member signature: VALUE (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);
	}

	public function testTokenPUBLIC() {
		var check = new MemberNameCheck ();
		check.tokens = [ "PUBLIC" ];

		var msg = checkMessage (MemberNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST2, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST1, new MemberNameCheck ());
		assertEquals ('Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST3, new MemberNameCheck ());
		assertEquals ('Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);
	}

	public function testTokenPRIVATE() {
		var check = new MemberNameCheck ();
		check.tokens = [ "PRIVATE" ];

		var msg = checkMessage (MemberNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST2, new MemberNameCheck ());
		assertEquals ('Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST3, new MemberNameCheck ());
		assertEquals ('Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);
	}

	public function testTokenENUM() {
		var check = new MemberNameCheck ();
		check.tokens = [ "ENUM" ];

		var msg = checkMessage (MemberNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST2, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST3, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST5, new MemberNameCheck ());
		assertEquals ('Invalid enum member signature: VALUE (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);
	}

	public function testTokenTYPEDEF() {
		var check = new MemberNameCheck ();
		check.tokens = [ "TYPEDEF" ];

		var msg = checkMessage (MemberNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST2, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST3, new MemberNameCheck ());
		assertEquals ('Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9_]*$/)', msg);
	}

	public function testFormat() {
		var check = new MemberNameCheck ();
		check.format = "^[A-Z]*$";

		var msg = checkMessage (MemberNameTests.TEST5, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST4, check);
		assertEquals ('', msg);

		msg = checkMessage (MemberNameTests.TEST, check);
		assertEquals ('Invalid typedef member signature: count2 (name should be ~/^[A-Z]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST1, check);
		assertEquals ('Invalid member signature: Count (name should be ~/^[A-Z]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST2, check);
		assertEquals ('Invalid member signature: Count (name should be ~/^[A-Z]*$/)', msg);

		msg = checkMessage (MemberNameTests.TEST3, check);
		assertEquals ('Invalid typedef member signature: Count (name should be ~/^[A-Z]*$/)', msg);
	}
}

class MemberNameTests {
	public static inline var TEST:String = "
	class Test {
		public var a:Int;
		private var b:Int;
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		var count5:Int = 1;
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
	class Test {
		public var Count:Int = 1;
		public function test() {
		}
	}";

	public static inline var TEST2:String = "
	class Test {
		var Count:Int = 1;
		public function test() {
		}
	}";

	public static inline var TEST3:String =
	"typedef Test = {
		var Count:Int;
	}";

	public static inline var TEST4:String =
	"extern class Test {
		var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";

	public static inline var TEST5:String =
	"enum Test {
		VALUE;
	}";

}
