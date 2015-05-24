package ;

import checkstyle.checks.ConstantNameCheck;

class ConstantNameCheckTest extends CheckTestCase {

	public function testCorrectNaming() {
		var msg = checkMessage (ConstantNameTests.TEST, new ConstantNameCheck ());
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST3, new ConstantNameCheck ());
		assertEquals ('', msg);
	}

	public function testWrongNaming() {
		var msg = checkMessage (ConstantNameTests.TEST1, new ConstantNameCheck ());
		assertEquals ('Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)', msg);

		msg = checkMessage (ConstantNameTests.TEST2, new ConstantNameCheck ());
		assertEquals ('Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)', msg);
	}

	public function testIgnoreExtern() {
		var check = new ConstantNameCheck ();
		check.ignoreExtern = false;

		var msg = checkMessage (ConstantNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST1, check);
		assertEquals ('Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)', msg);

		msg = checkMessage (ConstantNameTests.TEST2, check);
		assertEquals ('Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)', msg);

		msg = checkMessage (ConstantNameTests.TEST3, check);
		assertEquals ('Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)', msg);
	}

	public function testTokenINLINE() {
		var check = new ConstantNameCheck ();
		check.tokens = [ "INLINE" ];

		var msg = checkMessage (ConstantNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST3, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST2, check);
		assertEquals ('Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)', msg);
	}

	public function testTokenNOTINLINE() {
		var check = new ConstantNameCheck ();
		check.tokens = [ "NOTINLINE" ];

		var msg = checkMessage (ConstantNameTests.TEST, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST2, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST3, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST1, check);
		assertEquals ('Invalid const signature: Count (name should be ~/^[A-Z][A-Z0-9]*(_[A-Z0-9_]+)*$/)', msg);
	}

	public function testFormat() {
		var check = new ConstantNameCheck ();
		check.format = "^[A-Z][a-z]*$";

		var msg = checkMessage (ConstantNameTests.TEST1, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST2, check);
		assertEquals ('', msg);

		msg = checkMessage (ConstantNameTests.TEST3, check);
		assertEquals ('', msg);

		check.ignoreExtern = false;
		msg = checkMessage (ConstantNameTests.TEST3, check);
		assertEquals ('', msg);

		check.tokens = [ "INLINE" ];
		msg = checkMessage (ConstantNameTests.TEST, check);
		assertEquals ('Invalid const signature: COUNT2 (name should be ~/^[A-Z][a-z]*$/)', msg);
	}
}

class ConstantNameTests {
	public static inline var TEST:String = "
	class Test {
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		var COUNT3:Int = 1;
		var Count4:Int = 1;
		var count5:Int = 1;
		var _count5:Int = 1;
	}";

	public static inline var TEST1:String = "
	class Test {
		static var Count:Int = 1;
		public function test() {
		}
	}";

	public static inline var TEST2:String =
	"class Test {
		static inline var Count:Int = 1;
		public function test() {
			var Count:Int;
		}
	}";

	public static inline var TEST3:String =
	"extern class Test {
		static var Count:Int = 1;
		static inline var Count:Int = 1;
		public function test() {
		}
	}";
}
