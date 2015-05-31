package ;

import checkstyle.checks.MemberNameCheck;

// TODO abstract tests
class MemberNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new MemberNameCheck ();
		assertMsg(check, MemberNameTests.TEST, '');
		assertMsg(check, MemberNameTests.TEST4, '');
	}

	public function testWrongNaming() {
		var check = new MemberNameCheck ();
		assertMsg(check, MemberNameTests.TEST1, 'Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST2, 'Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST5, 'Invalid enum member signature: VALUE (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
	}

	public function testIgnoreExtern() {
		var check = new MemberNameCheck ();
		check.ignoreExtern = false;

		assertMsg(check, MemberNameTests.TEST, '');
		assertMsg(check, MemberNameTests.TEST1, 'Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST2, 'Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST4, 'Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST5, 'Invalid enum member signature: VALUE (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
	}

	public function testTokenPUBLIC() {
		var check = new MemberNameCheck ();
		check.tokens = [ "PUBLIC" ];

		assertMsg(check, MemberNameTests.TEST, '');
		assertMsg(check, MemberNameTests.TEST1, 'Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST2, '');
		assertMsg(check, MemberNameTests.TEST3, '');
		assertMsg(check, MemberNameTests.TEST4, '');
		assertMsg(check, MemberNameTests.TEST5, '');

		check.tokens = [ "PUBLIC", "TYPEDEF" ];
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
	}

	public function testTokenPRIVATE() {
		var check = new MemberNameCheck ();
		check.tokens = [ "PRIVATE" ];

		assertMsg(check, MemberNameTests.TEST, '');
		assertMsg(check, MemberNameTests.TEST1, '');
		assertMsg(check, MemberNameTests.TEST2, 'Invalid member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST3, '');
		assertMsg(check, MemberNameTests.TEST4, '');
		assertMsg(check, MemberNameTests.TEST5, '');

		check.tokens = [ "PRIVATE", "TYPEDEF" ];
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
	}

	public function testTokenENUM() {
		var check = new MemberNameCheck ();
		check.tokens = [ "ENUM" ];

		assertMsg(check, MemberNameTests.TEST, '');
		assertMsg(check, MemberNameTests.TEST1, '');
		assertMsg(check, MemberNameTests.TEST3, '');
		assertMsg(check, MemberNameTests.TEST4, '');
		assertMsg(check, MemberNameTests.TEST5, 'Invalid enum member signature: VALUE (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
	}

	public function testTokenTYPEDEF() {
		var check = new MemberNameCheck ();
		check.tokens = [ "TYPEDEF" ];

		assertMsg(check, MemberNameTests.TEST, '');
		assertMsg(check, MemberNameTests.TEST1, '');
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/^[a-z]+[a-zA-Z0-9]*$/)');
		assertMsg(check, MemberNameTests.TEST4, '');
		assertMsg(check, MemberNameTests.TEST5, '');
	}

	public function testFormat() {
		var check = new MemberNameCheck ();
		check.format = "^[A-Z]*$";

		assertMsg(check, MemberNameTests.TEST, 'Invalid typedef member signature: count2 (name should be ~/^[A-Z]*$/)');
		assertMsg(check, MemberNameTests.TEST1, 'Invalid member signature: Count (name should be ~/^[A-Z]*$/)');
		assertMsg(check, MemberNameTests.TEST2, 'Invalid member signature: Count (name should be ~/^[A-Z]*$/)');
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/^[A-Z]*$/)');
		assertMsg(check, MemberNameTests.TEST4, '');
		assertMsg(check, MemberNameTests.TEST5, '');
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
		@SuppressWarnings('checkstyle:MemberName')
		var COUNT6:Int = 1;
	}

	enum Test2 {
		count;
		a;
	}
	
	typedef Test3 = {
		var count1:Int;
		var count2:String;
		@SuppressWarnings('checkstyle:MemberName')
		var COUNT6:Int = 1;
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
