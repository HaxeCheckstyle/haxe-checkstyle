package checks;

import checkstyle.checks.AnonymousCheck;

class AnonymousCheckTest extends CheckTestCase {

	public function testAnonymousStructureClassVar() {
		assertMsg(new AnonymousCheck(), AnonymousTests.TEST1, 'Anonymous structure found, it is advised to use a typedef instead "anonymous"');
	}

	public function testAnonymousStructureLocalVar() {
		assertMsg(new AnonymousCheck(), AnonymousTests.TEST2, 'Anonymous structure found, it is advised to use a typedef instead "b"');
	}
}

class AnonymousTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		var anonymous:{a:Int, b:Int};
	}";

	public static inline var TEST2:String =
	"abstractAndClass Test {
		public function new() {
			var b:{a:Int, b:Int};
		}
	}";
}