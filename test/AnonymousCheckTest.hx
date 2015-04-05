package ;

import checkstyle.checks.AnonymousCheck;

class AnonymousCheckTest extends CheckTestCase {

	public function testAnonymousStructureClassVar(){
		var msg = checkMessage(AnonymousTests.TEST1, new AnonymousCheck());
		assertEquals(msg, 'Anonymous structure found, it is advised to use a typedef instead "_anonymous"');
	}

	public function testAnonymousStructureLocalVar(){
		var msg = checkMessage(AnonymousTests.TEST2, new AnonymousCheck());
		assertEquals(msg, 'Anonymous structure found, it is advised to use a typedef instead "b"');
	}
}

class AnonymousTests {
	public static inline var TEST1:String = "
	class Test {
		var _anonymous:{a:Int, b:Int};
	}";

	public static inline var TEST2:String =
	"class Test {
		public function new() {
			var b:{a:Int, b:Int};
		}
	}";
}