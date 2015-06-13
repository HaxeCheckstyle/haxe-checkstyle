package ;

import checkstyle.checks.EmptyBlockCheck;

class EmptyBlockCheckTest extends CheckTestCase {

	public function testCorrectEmptyBlock() {
		var check = new EmptyBlockCheck ();
		assertMsg(check, EmptyBlockTests.TEST, '');
		assertMsg(check, EmptyBlockTests.TEST2, '');
		assertMsg(check, EmptyBlockTests.TEST3, '');
		assertMsg(check, EmptyBlockTests.TEST5, '');
	}

	public function testWrongEmptyBlock() {
		var check = new EmptyBlockCheck ();
		assertMsg(check, EmptyBlockTests.TEST1, 'Empty block should be written as {}');
		assertMsg(check, EmptyBlockTests.TEST4, 'Empty block should be written as {}');
		assertMsg(check, EmptyBlockTests.TEST6, 'Empty block should be written as {}');
	}

	public function testOptionText () {
		var check = new EmptyBlockCheck ();
		check.option = EmptyBlockCheck.TEXT;

		assertMsg(check, EmptyBlockTests.TEST, 'Empty block should contain a comment');
		assertMsg(check, EmptyBlockTests.TEST1, 'Empty block should contain a comment');
		assertMsg(check, EmptyBlockTests.TEST2, '');
		assertMsg(check, EmptyBlockTests.TEST3, 'Empty block should contain a comment');
		assertMsg(check, EmptyBlockTests.TEST4, 'Empty block should contain a comment');
		assertMsg(check, EmptyBlockTests.TEST5, '');
	}
}

class EmptyBlockTests {
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
		public function new() {
			// comment
		}
	}";

	public static inline var TEST3:String =
	"class Test {
		public function new() {
			var a = {};
		}
	}";

	public static inline var TEST4:String = "
	class Test {
		public function new() {
			var a = {
			};
		}
	}";

	public static inline var TEST5:String = "
	class Test {
		public function new() {
			var a = {
				// comment
			};
		}
	}";

	public static inline var TEST6:String = "
	class Test {
		public function new() {
		}
	}";
}