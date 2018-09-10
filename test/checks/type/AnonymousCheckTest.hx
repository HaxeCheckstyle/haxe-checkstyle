package checks.type;

import checkstyle.checks.type.AnonymousCheck;

class AnonymousCheckTest extends CheckTestCase<AnonymousCheckTests> {
	@Test
	public function testAnonymousStructureClassVar() {
		assertMsg(new AnonymousCheck(), TEST1, 'Anonymous structure "anonymous" found, use "typedef"');
	}

	@Test
	public function testAnonymousStructureLocalVar() {
		assertMsg(new AnonymousCheck(), TEST2, 'Anonymous structure "b" found, use "typedef"');
	}
}

@:enum
abstract AnonymousCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var anonymous:{a:Int, b:Int};
	}";
	var TEST2 = "
	abstractAndClass Test {
		public function new() {
			var b:{a:Int, b:Int};
		}
	}";
}