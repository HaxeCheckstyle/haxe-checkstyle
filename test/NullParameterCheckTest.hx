package;

import checkstyle.checks.NullParameterCheck;

class NullParameterCheckTest extends CheckTestCase {

	public function testDetectRedundancy() {
		assertMsg(new NullParameterCheck(), NullParameterCheckTests.TEST1,
			"Parameter a has a '?' and a default value of 'null', which is redundant");
	}

	public function testSuppressRedundancy() {
		assertMsg(new NullParameterCheck(), NullParameterCheckTests.TEST2, '');
	}
	
	public function testNoRedundancy() {
		assertMsg(new NullParameterCheck(), NullParameterCheckTests.TEST3, '');
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
		function test(?a:Int = null) {}
	}";
	
	public static inline var TEST3:String = "
	abstractAndClass Test {
		function test(?a:Int, b:Null<Int> = null) {}
	}";
}