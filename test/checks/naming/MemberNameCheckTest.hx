package checks.naming;

import checkstyle.checks.naming.MemberNameCheck;

class MemberNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new MemberNameCheck ();
		assertNoMsg(check, MemberNameTests.TEST);
		assertNoMsg(check, MemberNameTests.TEST4);
	}

	public function testWrongNaming() {
		var check = new MemberNameCheck ();
		assertMsg(check, MemberNameTests.TEST1, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST2, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST5, 'Invalid enum member signature: VALUE_TEST (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.PROPERTY_NAME, 'Invalid member signature: Example (name should be ~/^[a-z][a-zA-Z0-9]*$/)');
	}

	public function testIgnoreExtern() {
		var check = new MemberNameCheck ();
		check.ignoreExtern = false;

		var memberMessage = 'Invalid member signature: Count (name should be ~/${check.format}/)';
		assertNoMsg(check, MemberNameTests.TEST);
		assertMsg(check, MemberNameTests.TEST1, memberMessage);
		assertMsg(check, MemberNameTests.TEST2, memberMessage);
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST4, memberMessage);
		assertMsg(check, MemberNameTests.TEST5, 'Invalid enum member signature: VALUE_TEST (name should be ~/${check.format}/)');
	}

	public function testTokenPublic() {
		var check = new MemberNameCheck ();
		check.tokens = [MemberNameCheck.CLASS, MemberNameCheck.PUBLIC];

		var memberMessage = 'Invalid member signature: Count (name should be ~/${check.format}/)';
		assertNoMsg(check, MemberNameTests.TEST);
		assertMsg(check, MemberNameTests.TEST1, memberMessage);
		assertNoMsg(check, MemberNameTests.TEST2);
		assertNoMsg(check, MemberNameTests.TEST3);
		assertNoMsg(check, MemberNameTests.TEST4);
		assertNoMsg(check, MemberNameTests.TEST5);

		check.tokens = [MemberNameCheck.PUBLIC, MemberNameCheck.TYPEDEF];
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
	}

	public function testTokenPrivate() {
		var check = new MemberNameCheck ();
		check.tokens = [MemberNameCheck.CLASS, MemberNameCheck.PRIVATE];

		assertNoMsg(check, MemberNameTests.TEST);
		assertNoMsg(check, MemberNameTests.TEST1);
		assertMsg(check, MemberNameTests.TEST2, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertNoMsg(check, MemberNameTests.TEST3);
		assertNoMsg(check, MemberNameTests.TEST4);
		assertNoMsg(check, MemberNameTests.TEST5);

		check.tokens = [MemberNameCheck.PRIVATE, MemberNameCheck.TYPEDEF];
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
	}

	public function testTokenEnum() {
		var check = new MemberNameCheck ();
		check.tokens = [MemberNameCheck.ENUM];

		assertNoMsg(check, MemberNameTests.TEST);
		assertNoMsg(check, MemberNameTests.TEST1);
		assertNoMsg(check, MemberNameTests.TEST3);
		assertNoMsg(check, MemberNameTests.TEST4);
		assertMsg(check, MemberNameTests.TEST5, 'Invalid enum member signature: VALUE_TEST (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST6, 'Invalid enum member signature: VALUE (name should be ~/${check.format}/)');
	}

	public function testTokenTypedef() {
		var check = new MemberNameCheck ();
		check.tokens = [MemberNameCheck.TYPEDEF];

		assertNoMsg(check, MemberNameTests.TEST);
		assertNoMsg(check, MemberNameTests.TEST1);
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
		assertNoMsg(check, MemberNameTests.TEST4);
		assertNoMsg(check, MemberNameTests.TEST5);
	}

	public function testFormat() {
		var check = new MemberNameCheck ();
		check.format = "^[A-Z_]*$";

		assertMsg(check, MemberNameTests.TEST, 'Invalid typedef member signature: count2 (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST1, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST2, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
		assertNoMsg(check, MemberNameTests.TEST4);
		assertNoMsg(check, MemberNameTests.TEST5);
		assertNoMsg(check, MemberNameTests.TEST6);
		assertMsg(check, MemberNameTests.ABSTRACT_FIELDS, 'Invalid member signature: EnumConstructor3 (name should be ~/${check.format}/)');

		check.format = "^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$";
		assertMsg(check, MemberNameTests.TEST5, 'Invalid enum member signature: VALUE_TEST_ (name should be ~/${check.format}/)');
		assertMsg(check, MemberNameTests.TEST6, 'Invalid enum member signature: VALUE_ (name should be ~/${check.format}/)');
	}

	public function testTokenAbstract() {
		var check = new MemberNameCheck ();
		check.tokens = [MemberNameCheck.ABSTRACT, MemberNameCheck.PUBLIC, MemberNameCheck.PRIVATE];
		check.format = "^[A-Z_]*$";

		assertNoMsg(check, MemberNameTests.TEST);
		assertMsg(check, MemberNameTests.ABSTRACT_FIELDS, 'Invalid member signature: EnumConstructor3 (name should be ~/${check.format}/)');

		check.tokens = [MemberNameCheck.ABSTRACT, MemberNameCheck.PUBLIC];
		assertNoMsg(check, MemberNameTests.ABSTRACT_FIELDS);

		check.tokens = [MemberNameCheck.ABSTRACT, MemberNameCheck.PRIVATE];
		assertMsg(check, MemberNameTests.ABSTRACT_FIELDS, 'Invalid member signature: EnumConstructor3 (name should be ~/${check.format}/)');
	}
}

class MemberNameTests {
	public static inline var TEST:String = "
	class Test {
		public var a:Int;
		private var b:Int;
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		public var example(default, null):Int;
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
		VALUE_TEST_;
		VALUE_TEST;
	}";

	public static inline var TEST6:String =
	"enum Test {
		VALUE_;
		VALUE;
	}";

	public static inline var ABSTRACT_FIELDS:String =
	"@:enum abstract MyAbstract(Int) from Int to Int
	{
		static public inline var NORMAL_CONST = 'hello, world';

		var EnumConstructor1 = 1;
		var EnumConstructor2 = 2;
		var EnumConstructor3 = 3;

		static public function doSomething () : Void trace(NORMAL_CONST);
	}";

	public static inline var PROPERTY_NAME:String = "
	class Test {
		public var Example(default, null):Int;
	}";

}