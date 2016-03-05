package checks.naming;

import checkstyle.checks.naming.LocalVariableNameCheck;

class LocalVariableNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var check = new LocalVariableNameCheck ();
		assertNoMsg(check, LocalVariableNameTests.TEST);
		assertNoMsg(check, LocalVariableNameTests.TEST4);
	}

	public function testWrongNaming() {
		var check = new LocalVariableNameCheck ();
		var message = 'Invalid local var signature: Count (name should be ~/${check.format}/)';
		assertMsg(check, LocalVariableNameTests.TEST1, message);
		assertMsg(check, LocalVariableNameTests.TEST3, message);
	}

	public function testIgnoreExtern() {
		var check = new LocalVariableNameCheck ();
		check.ignoreExtern = false;

		assertNoMsg(check, LocalVariableNameTests.TEST);

		var message = 'Invalid local var signature: Count (name should be ~/${check.format}/)';
		assertMsg(check, LocalVariableNameTests.TEST1, message);
		assertMsg(check, LocalVariableNameTests.TEST3, message);
		assertMsg(check, LocalVariableNameTests.TEST4, message);
	}

	public function testFormat() {
		var check = new LocalVariableNameCheck ();
		check.format = "^[A-Za-z_]*$";

		assertMsg(check, LocalVariableNameTests.TEST, 'Invalid local var signature: count2 (name should be ~/${check.format}/)');
		assertNoMsg(check, LocalVariableNameTests.TEST1);
		assertNoMsg(check, LocalVariableNameTests.TEST3);
		assertNoMsg(check, LocalVariableNameTests.TEST4);
	}
}

class LocalVariableNameTests {
	public static inline var TEST:String = "
	class Test {
		public function test() {
			var a:Int;
			var b:Int;
		}
		@SuppressWarnings('checkstyle:LocalVariableName')
		public function test() {
			var I:Int;
		}
	}

	enum Test2 {
		count;
		a;
	}

	typedef Test3 = {
		public function test() {
			var count1:Int;
			var count2:String;
		};
		@SuppressWarnings('checkstyle:LocalVariableName')
		var COUNT6:Int = 1;
	}

	typedef Test4 = {
		@SuppressWarnings('checkstyle:LocalVariableName')
		public function test() {
			var Count1:Int;
		};
	}";

	public static inline var TEST1:String = "
	class Test {
		public function test() {
			var Count:Int = 1;
		}
	}";

	public static inline var TEST3:String =
	"typedef Test = {
		public function test() {
			var Count:Int;
		}
	}";

	public static inline var TEST4:String =
	"extern class Test {
		public function test() {
			var Count:Int = 1;
		}
	}";
}