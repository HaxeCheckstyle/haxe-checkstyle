package checks.naming;

import checkstyle.checks.naming.MemberNameCheck;

class MemberNameCheckTest extends CheckTestCase<MemberNameCheckTests> {

	public function testCorrectNaming() {
		var check = new MemberNameCheck ();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST4);
	}

	public function testWrongNaming() {
		var check = new MemberNameCheck ();
		assertMsg(check, TEST1, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, TEST2, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, TEST5, 'Invalid enum member signature: VALUE_TEST (name should be ~/${check.format}/)');
		assertMsg(check, PROPERTY_NAME, 'Invalid member signature: Example (name should be ~/^[a-z][a-zA-Z0-9]*$/)');
	}

	public function testIgnoreExtern() {
		var check = new MemberNameCheck ();
		check.ignoreExtern = false;

		var memberMessage = 'Invalid member signature: Count (name should be ~/${check.format}/)';
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, memberMessage);
		assertMsg(check, TEST2, memberMessage);
		assertMsg(check, TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, TEST4, memberMessage);
		assertMsg(check, TEST5, 'Invalid enum member signature: VALUE_TEST (name should be ~/${check.format}/)');
	}

	public function testTokenPublic() {
		var check = new MemberNameCheck ();
		check.tokens = [CLASS, PUBLIC];

		var memberMessage = 'Invalid member signature: Count (name should be ~/${check.format}/)';
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, memberMessage);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);

		check.tokens = [PUBLIC, TYPEDEF];
		assertMsg(check, TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
	}

	public function testTokenPrivate() {
		var check = new MemberNameCheck ();
		check.tokens = [CLASS, PRIVATE];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);

		check.tokens = [PRIVATE, TYPEDEF];
		assertMsg(check, TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
	}

	public function testTokenEnum() {
		var check = new MemberNameCheck ();
		check.tokens = [ENUM];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertMsg(check, TEST5, 'Invalid enum member signature: VALUE_TEST (name should be ~/${check.format}/)');
		assertMsg(check, TEST6, 'Invalid enum member signature: VALUE (name should be ~/${check.format}/)');
	}

	public function testTokenTypedef() {
		var check = new MemberNameCheck ();
		check.tokens = [TYPEDEF];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
	}

	public function testFormat() {
		var check = new MemberNameCheck ();
		check.format = "^[A-Z_]*$";

		assertMsg(check, TEST, 'Invalid typedef member signature: count2 (name should be ~/${check.format}/)');
		assertMsg(check, TEST1, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, TEST2, 'Invalid member signature: Count (name should be ~/${check.format}/)');
		assertMsg(check, TEST3, 'Invalid typedef member signature: Count (name should be ~/${check.format}/)');
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, TEST6);
		assertMsg(check, ABSTRACT_FIELDS, 'Invalid member signature: EnumConstructor3 (name should be ~/${check.format}/)');

		check.format = "^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$";
		assertMsg(check, TEST5, 'Invalid enum member signature: VALUE_TEST_ (name should be ~/${check.format}/)');
		assertMsg(check, TEST6, 'Invalid enum member signature: VALUE_ (name should be ~/${check.format}/)');
	}

	public function testTokenAbstract() {
		var check = new MemberNameCheck ();
		check.tokens = [ABSTRACT, PUBLIC, PRIVATE];
		check.format = "^[A-Z_]*$";

		assertNoMsg(check, TEST);
		assertMsg(check, ABSTRACT_FIELDS, 'Invalid member signature: EnumConstructor3 (name should be ~/${check.format}/)');

		check.tokens = [ABSTRACT, PRIVATE];
		assertNoMsg(check, ABSTRACT_FIELDS);

		check.tokens = [ABSTRACT, PUBLIC];
		assertMsg(check, ABSTRACT_FIELDS, 'Invalid member signature: EnumConstructor3 (name should be ~/${check.format}/)');
	}

	public function testDefineCombinations() {
		var check = new MemberNameCheck();
		assertNoMsg(check, DEFINE_COMBINATIONS);
		assertMsg(check, DEFINE_COMBINATIONS, 'Invalid member signature: Violation (name should be ~/${check.format}/)', [["flash"]]);
	}
}

@:enum
abstract MemberNameCheckTests(String) to String {
	var TEST = "
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

	var TEST1 = "
	class Test {
		public var Count:Int = 1;
		public function test() {
		}
	}";

	var TEST2 = "
	class Test {
		var Count:Int = 1;
		public function test() {
		}
	}";

	var TEST3 =
	"typedef Test = {
		var Count:Int;
	}";

	var TEST4 =
	"extern class Test {
		var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";

	var TEST5 =
	"enum Test {
		VALUE_TEST_;
		VALUE_TEST;
	}";

	var TEST6 =
	"enum Test {
		VALUE_;
		VALUE;
	}";

	var ABSTRACT_FIELDS =
	"@:enum abstract MyAbstract(Int) from Int to Int
	{
		static public inline var NORMAL_CONST = 'hello, world';

		var EnumConstructor1 = 1;
		var EnumConstructor2 = 2;
		var EnumConstructor3 = 3;

		static public function doSomething () : Void trace(NORMAL_CONST);
	}";

	var PROPERTY_NAME = "
	class Test {
		public var Example(default, null):Int;
	}";

	var DEFINE_COMBINATIONS = "
	class Test {
		#if flash
		public var Violation:Int;
		#else
		public var okName:Int;
		#end
	}";
}