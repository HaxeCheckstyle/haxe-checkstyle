package ;

import checkstyle.checks.BlockFormatCheck;

class BlockFormatCheckTest extends CheckTestCase {

	public function testCorrectBlockFormat(){
		var msg = checkMessage(BlockFormatTests.TEST, new BlockFormatCheck());
		assertEquals(msg, '');
	}

	public function testWrongBlockFormat(){
		var msg = checkMessage(BlockFormatTests.TEST1, new BlockFormatCheck());
		assertEquals(msg, 'Empty block should be written as {}');
	}

	public function testBlockFormatFirstLine(){
		var msg = checkMessage(BlockFormatTests.TEST2, new BlockFormatCheck());
		assertEquals(msg, 'First line of multiline block should contain only {');
	}

	public function testBlockFormatLastLine(){
		var msg = checkMessage(BlockFormatTests.TEST3, new BlockFormatCheck());
		assertEquals(msg, 'Last line of multiline block should contain only } and maybe , or ;');
	}
}

class BlockFormatTests {
	public static inline var TEST:String = "
	class Test {
		public function new() {}
	}";

	public static inline var TEST1:String = "
	class Test {
		public function new(){

		}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function new() { var a:Int;

		}
	}";

	public static inline var TEST3:String =
	"class Test {
		public function new() {
			var a:Int; }
	}";
}