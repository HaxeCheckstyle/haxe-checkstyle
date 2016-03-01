package;

import checkstyle.checks.NullParameterCheck;

class NullParameterCheckTest extends CheckTestCase {

	public function testDetectRedundancy() {
		assertMsg(new NullParameterCheck(), NullParameterCheckTests.TEST1,
			"Parameter 'a' is marked as optional with '?' and has a default value of 'null', which is redundant");
	}

	public function testSuppress() {
		assertMsg(new NullParameterCheck(), NullParameterCheckTests.TEST2, '');
	}
	
	public function testAllowEitherStyle() {
		var check = new NullParameterCheck();
		check.nullDefaultValueStyle = NullParameterCheck.EITHER;
		assertMsg(check, NullParameterCheckTests.TEST3, '');
	}

	public function testPreferQuestionMark() {
		var check = new NullParameterCheck();
		check.nullDefaultValueStyle = NullParameterCheck.QUESTION_MARK;
		assertMsg(check, NullParameterCheckTests.TEST3,
			"Parameter 'b' should be marked as optional with '?' instead of using a null default value");
	}

	public function testPreferNull() {
		var check = new NullParameterCheck();
		check.nullDefaultValueStyle = NullParameterCheck.NULL;
		assertMsg(check, NullParameterCheckTests.TEST3,
			"Parameter 'a' should have a null default value instead of being marked as optional with '?'");
	}
}

class NullParameterCheckTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		function test(?a:Int = null) {}
	}";
	
	public static inline var TEST2:String = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:NullParameter')
		function test(?a:Int = null, b:Null<Int> = null, ?c:Int) {}
	}";
	
	public static inline var TEST3:String = "
	abstractAndClass Test {
		function test(?a:Int, b:Null<Int> = null) {}
	}";
}