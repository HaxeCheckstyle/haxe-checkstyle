import checkstyle.checks.FileLengthCheck;

class FileLengthCheckTest extends CheckTestCase {

	public function testCorrectLineCount() {
		var msg = checkMessage(FileLengthTests.TEST, new FileLengthCheck());
		assertEquals('', msg);
	}

	public function testConfigurableFileLength() {
		var check = new FileLengthCheck();
		check.max = 30;

		var msg = checkMessage(FileLengthTests.TEST, check);
		assertEquals('Too many lines in file (> 30)', msg);
	}

	public function testSupressFileLength() {
		var check = new FileLengthCheck();
		check.max = 20;

		var msg = checkMessage(FileLengthTests.TEST2, check);
		assertEquals('', msg);
	}
}

class FileLengthTests {
	
	public static inline var TEST:String = "
	class Test {
		public function new() {
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
		}
	}";

	public static inline var TEST2:String = "
	@SuppressWarnings('checkstyle:FileLength')
	class Test {
		public function new() {
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
			//
		}
	}";
}