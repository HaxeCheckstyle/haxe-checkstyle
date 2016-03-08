package checks.type;

import checkstyle.checks.type.AnonymousCheck;

class AnonymousCheckTest extends CheckTestCase<AnonymousCheckTests> {

	public function testAnonymousStructureClassVar() {
		assertMsg(new AnonymousCheck(), TEST1, 'Anonymous structure found, it is advised to use a typedef instead "anonymous"');
	}

	public function testAnonymousStructureLocalVar() {
		assertMsg(new AnonymousCheck(), TEST2, 'Anonymous structure found, it is advised to use a typedef instead "b"');
	}
}

@:enum
abstract AnonymousCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var anonymous:{a:Int, b:Int};
	}";

	var TEST2 =
	"abstractAndClass Test {
		public function new() {
			var b:{a:Int, b:Int};
		}
	}";
}