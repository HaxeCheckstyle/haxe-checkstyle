package ;

import checkstyle.checks.ERegInstantiationCheck;

class ERegInstantiationCheckTest extends CheckTestCase {

	public function testCorrectEReg() {
		var msg = checkMessage(ERegInstantiationTests.TEST1, new ERegInstantiationCheck());
		assertEquals(msg, 'Bad EReg instantiation, define expression between ~/ and /');
	}

	public function testWrongEReg() {
		var msg = checkMessage(ERegInstantiationTests.TEST2, new ERegInstantiationCheck());
		assertEquals(msg, '');
	}

	public function testIssue43() {
		var msg = checkMessage(ERegInstantiationTests.ISSUE_43, new ERegInstantiationCheck());
		assertEquals(msg, '');
	}
}

class ERegInstantiationTests {
	public static inline var TEST1:String = "
	class Test {
		var _reg:EReg = new EReg('test', 'i');
	}";

	public static inline var TEST2:String =
	"class Test {
		var _reg:EReg = ~/test/i;
	}";

	public static inline var ISSUE_43:String =
	"class Test {
		function test() {
			cast (Type.createInstance(Array, []));
		}
	}";
}