package ;

import checkstyle.checks.BlockFormatCheck;

class BlockFormatCheckTest extends CheckTestCase {

	public function testCorrectBlockFormat() {
		var check:BlockFormatCheck = new BlockFormatCheck();
		assertMsg(check, BlockFormatTests.TEST, '');
		assertMsg(check, BlockFormatTests.BLOCK_COMMENT, '');
	}

	public function testWrongBlockFormat() {
		var check:BlockFormatCheck = new BlockFormatCheck();
		assertMsg(check, BlockFormatTests.TEST1, 'Empty block should be written as {}');
	}

	public function testBlockFormatFirstLine() {
		var msg = checkMessage(BlockFormatTests.TEST2, new BlockFormatCheck());
		assertEquals(msg, 'First line of multiline block should contain only {');
	}

	public function testBlockFormatLastLine() {
		var msg = checkMessage(BlockFormatTests.TEST3, new BlockFormatCheck());
		assertEquals(msg, 'Last line of multiline block should contain only } and maybe , or ;');
	}

	public function testWrongEmptyBlock() {
		var msg = checkMessage(BlockFormatTests.TEST4, new BlockFormatCheck());
		assertEquals(msg, 'Empty block should be written as {}');
	}

	public function testOptionText () {
		var check = new BlockFormatCheck();
		check.option = BlockFormatCheck.TEXT;
		assertEquals(checkMessage(BlockFormatTests.TEST4, check), 'Empty block should contain a comment');
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

	public static inline var TEST4:String = "
	class Test {
		public function new(){

		}
	}";

	public static inline var TEST5:String =
	"class Test {
		public function new() {
			// comment
		}
	}";

	public static inline var TEST6:String =
	"class Test {
		public function new() {
			var a = {};
		}
	}";

	public static inline var TEST7:String = "
	class Test {
		public function new() {
			var a = {
			};
		}
	}";

	public static inline var TEST8:String = "
	class Test {
		public function new() {
			var a = {
				// comment
			};
		}
	}";

	public static inline var BLOCK_COMMENT:String = "
	class Test {                                  
		public function new() { /* comment
								 */
			var a = { // comment
			};
		}
	}";
}