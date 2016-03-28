package checks.literal;

import checkstyle.checks.literal.ERegLiteralCheck;

class ERegLiteralCheckTest extends CheckTestCase<ERegLiteralCheckTests> {

	public function testCorrectEReg() {
		assertNoMsg(new ERegLiteralCheck(), TEST2);
	}

	public function testWrongEReg() {
		assertMsg(new ERegLiteralCheck(), TEST1, 'Bad EReg instantiation, define expression between "~/" and "/"');
	}

	public function testIssue43() {
		assertNoMsg(new ERegLiteralCheck(), ISSUE_43);
	}

	public function testIssue99() {
		assertNoMsg(new ERegLiteralCheck(), REGEX_WITH_STRING_INTERPOLATION);
	}
}

@:enum
abstract ERegLiteralCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var _reg:EReg = new EReg('test', 'i');
	}";

	var TEST2 =
	"abstractAndClass Test {
		var _reg:EReg = ~/test/i;
	}";

	var ISSUE_43 =
	"abstractAndClass Test {
		function test() {
			cast (Type.createInstance(Array, []));
		}
	}";

	var REGEX_WITH_STRING_INTERPOLATION =
	"abstractAndClass Test {
		var regex = new EReg('^${pattern}$', 'ig');
	}";
}