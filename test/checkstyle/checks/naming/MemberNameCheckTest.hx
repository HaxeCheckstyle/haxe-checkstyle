package checkstyle.checks.naming;

class MemberNameCheckTest extends CheckTestCase<MemberNameCheckTests> {
	@Test
	public function testCorrectNaming() {
		var check = new MemberNameCheck();
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST4);
	}

	@Test
	public function testWrongNaming() {
		var check = new MemberNameCheck();
		assertMsg(check, TEST1, 'Invalid member signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST2, 'Invalid member signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST3, 'Invalid typedef member signature: "Count" (name should be "~/${check.format}/")');
		assertMessages(check, TEST5, [
			'Invalid enum member signature: "VALUE_TEST_" (name should be "~/^[a-z][a-zA-Z0-9]*$/")',
			'Invalid enum member signature: "VALUE_TEST" (name should be "~/${check.format}/")'
		]);
		assertMsg(check, PROPERTY_NAME, 'Invalid member signature: "Example" (name should be "~/^[a-z][a-zA-Z0-9]*$/")');
		assertMessages(check, ABSTRACT_FIELDS, [
			'Invalid member signature: "EnumConstructor1" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor2" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor3" (name should be "~/${check.format}/")'
		]);
	}

	@Test
	public function testIgnoreExtern() {
		var check = new MemberNameCheck();
		check.ignoreExtern = false;

		var memberMessage = 'Invalid member signature: "Count" (name should be "~/${check.format}/")';
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, memberMessage);
		assertMsg(check, TEST2, memberMessage);
		assertMsg(check, TEST3, 'Invalid typedef member signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST4, memberMessage);
		assertMessages(check, TEST5, [
			'Invalid enum member signature: "VALUE_TEST_" (name should be "~/^[a-z][a-zA-Z0-9]*$/")',
			'Invalid enum member signature: "VALUE_TEST" (name should be "~/${check.format}/")'
		]);
	}

	@Test
	public function testTokenClass() {
		var check = new MemberNameCheck();
		check.tokens = [CLASS];

		var memberMessage = 'Invalid member signature: "Count" (name should be "~/${check.format}/")';
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, memberMessage);
		assertMsg(check, TEST2, 'Invalid member signature: "Count" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, ABSTRACT_FIELDS);
	}

	@Test
	public function testTokenPublic() {
		var check = new MemberNameCheck();
		check.tokens = [CLASS, PUBLIC];

		var memberMessage = 'Invalid member signature: "Count" (name should be "~/${check.format}/")';
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, memberMessage);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, ABSTRACT_FIELDS);

		check.tokens = [PUBLIC];
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, memberMessage);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);

		check.tokens = [ABSTRACT, CLASS, PUBLIC];
		assertNoMsg(check, TEST);
		assertMsg(check, TEST1, memberMessage);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);

		check.tokens = [PUBLIC, TYPEDEF];
		assertMsg(check, TEST3, 'Invalid typedef member signature: "Count" (name should be "~/${check.format}/")');
	}

	@Test
	public function testTokenPrivate() {
		var check = new MemberNameCheck();
		check.tokens = [CLASS, PRIVATE];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid member signature: "Count" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, ABSTRACT_FIELDS);

		check.tokens = [PRIVATE];
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid member signature: "Count" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);

		check.tokens = [ABSTRACT, CLASS, PRIVATE];
		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST2, 'Invalid member signature: "Count" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);

		check.tokens = [PRIVATE, TYPEDEF];
		assertMsg(check, TEST3, 'Invalid typedef member signature: "Count" (name should be "~/${check.format}/")');
	}

	@Test
	public function testTokenEnum() {
		var check = new MemberNameCheck();
		check.tokens = [ENUM];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
		assertMessages(check, TEST5, [
			'Invalid enum member signature: "VALUE_TEST_" (name should be "~/${check.format}/")',
			'Invalid enum member signature: "VALUE_TEST" (name should be "~/${check.format}/")'
		]);
		assertMessages(check, TEST6, [
			'Invalid enum member signature: "VALUE_" (name should be "~/${check.format}/")',
			'Invalid enum member signature: "VALUE" (name should be "~/${check.format}/")'
		]);
		assertNoMsg(check, ABSTRACT_FIELDS);
	}

	@Test
	public function testTokenTypedef() {
		var check = new MemberNameCheck();
		check.tokens = [TYPEDEF];

		assertNoMsg(check, TEST);
		assertNoMsg(check, TEST1);
		assertMsg(check, TEST3, 'Invalid typedef member signature: "Count" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, ABSTRACT_FIELDS);
	}

	@Test
	public function testFormat() {
		var check = new MemberNameCheck();
		check.format = "^[A-Z_]*$";

		assertMessages(check, TEST, [
			'Invalid member signature: "a" (name should be "~/${check.format}/")',
			'Invalid member signature: "b" (name should be "~/${check.format}/")',
			'Invalid member signature: "example" (name should be "~/${check.format}/")',
			'Invalid member signature: "count5" (name should be "~/${check.format}/")',
			'Invalid enum member signature: "count" (name should be "~/${check.format}/")',
			'Invalid enum member signature: "a" (name should be "~/${check.format}/")',
			'Invalid typedef member signature: "count1" (name should be "~/${check.format}/")',
			'Invalid typedef member signature: "count2" (name should be "~/${check.format}/")'
		]);
		assertMsg(check, TEST1, 'Invalid member signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST2, 'Invalid member signature: "Count" (name should be "~/${check.format}/")');
		assertMsg(check, TEST3, 'Invalid typedef member signature: "Count" (name should be "~/${check.format}/")');
		assertNoMsg(check, TEST4);
		assertNoMsg(check, TEST5);
		assertNoMsg(check, TEST6);
		assertMessages(check, ABSTRACT_FIELDS, [
			'Invalid member signature: "EnumConstructor1" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor2" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor3" (name should be "~/${check.format}/")'
		]);

		check.format = "^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$";
		assertMsg(check, TEST5, 'Invalid enum member signature: "VALUE_TEST_" (name should be "~/${check.format}/")');
		assertMsg(check, TEST6, 'Invalid enum member signature: "VALUE_" (name should be "~/${check.format}/")');
	}

	@Test
	public function testTokenAbstract() {
		var check = new MemberNameCheck();
		check.tokens = [ABSTRACT, PUBLIC, PRIVATE];
		check.format = "^[A-Z_]*$";

		assertNoMsg(check, TEST);
		assertMessages(check, ABSTRACT_FIELDS, [
			'Invalid member signature: "EnumConstructor1" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor2" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor3" (name should be "~/${check.format}/")'
		]);

		check.tokens = [ABSTRACT];
		assertNoMsg(check, TEST);
		assertMessages(check, ABSTRACT_FIELDS, [
			'Invalid member signature: "EnumConstructor1" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor2" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor3" (name should be "~/${check.format}/")'
		]);

		check.tokens = [ABSTRACT, PRIVATE];
		assertNoMsg(check, ABSTRACT_FIELDS);

		check.tokens = [PRIVATE];
		assertNoMsg(check, ABSTRACT_FIELDS);

		check.tokens = [ABSTRACT, CLASS, PRIVATE];
		assertNoMsg(check, ABSTRACT_FIELDS);

		check.tokens = [ABSTRACT, PUBLIC];
		assertMessages(check, ABSTRACT_FIELDS, [
			'Invalid member signature: "EnumConstructor1" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor2" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor3" (name should be "~/${check.format}/")'
		]);

		check.tokens = [PUBLIC];
		assertMessages(check, ABSTRACT_FIELDS, [
			'Invalid member signature: "EnumConstructor1" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor2" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor3" (name should be "~/${check.format}/")'
		]);

		check.tokens = [ABSTRACT, CLASS, PUBLIC];
		assertMessages(check, ABSTRACT_FIELDS, [
			'Invalid member signature: "EnumConstructor1" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor2" (name should be "~/${check.format}/")',
			'Invalid member signature: "EnumConstructor3" (name should be "~/${check.format}/")'
		]);
	}

	@Test
	public function testDefineCombinations() {
		var check = new MemberNameCheck();
		assertNoMsg(check, DEFINE_COMBINATIONS);
		assertMsg(check, DEFINE_COMBINATIONS, 'Invalid member signature: "Violation" (name should be "~/${check.format}/")', [["flash"]]);
	}
}

enum abstract MemberNameCheckTests(String) to String {
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
	var TEST3 = "
	typedef Test = {
		var Count:Int;
	}";
	var TEST4 = "
	extern class Test {
		var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";
	var TEST5 = "
	enum Test {
		VALUE_TEST_;
		VALUE_TEST;
	}";
	var TEST6 = "
	enum Test {
		VALUE_;
		VALUE;
	}";
	var ABSTRACT_FIELDS = "
	enum abstract MyAbstract(Int) from Int to Int
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