package checks.whitespace;

import checkstyle.checks.whitespace.EmptyLinesCheck;

class EmptyLinesCheckTest extends CheckTestCase<EmptyLinesCheckTests> {

	static inline var MSG_TOO_MANY:String = "Too many consecutive empty lines (> 1)";
	static inline var MSG_AFTER_COMMENT:String = "Empty line not allowed after comment(s)";

	@Test
	public function testDefaultEmptyLines() {
		assertMsg(new EmptyLinesCheck(), TEST1, MSG_TOO_MANY);
	}

	@Test
	public function testCorrectEmptyLines() {
		assertNoMsg(new EmptyLinesCheck(), TEST2);
	}

	@Test
	public function testConfigurableEmptyLines() {
		var check = new EmptyLinesCheck();
		check.max = 2;
		assertNoMsg(check, TEST3);
	}

	@Test
	public function testEmptyLineAfterSingleLineComment() {
		var check = new EmptyLinesCheck();
		check.allowEmptyLineAfterSingleLineComment = false;

		assertMsg(check, TEST4, MSG_AFTER_COMMENT);
		assertMsg(check, TEST5, MSG_AFTER_COMMENT);
	}

	@Test
	public function testEmptyLineAfterMultiLineComment() {
		var check = new EmptyLinesCheck();
		check.allowEmptyLineAfterMultiLineComment = false;

		assertMsg(check, TEST6, MSG_AFTER_COMMENT);
		assertMsg(check, TEST7, MSG_AFTER_COMMENT);
	}

	@Test
	public function testAllowEmptyLineAfterComment() {
		assertNoMsg(new EmptyLinesCheck(), TEST4);
		assertNoMsg(new EmptyLinesCheck(), TEST5);
		assertNoMsg(new EmptyLinesCheck(), TEST6);
		assertNoMsg(new EmptyLinesCheck(), TEST7);
	}

	@Test
	public function testRequireEmptyLineAfterPackage() {
		assertMsg(new EmptyLinesCheck(), TEST8, "Empty line required after package declaration");
		assertNoMsg(new EmptyLinesCheck(), TEST9);
	}

	@Test
	public function testRequireEmptyLineAfterClass() {
		assertMsg(new EmptyLinesCheck(), TEST10, "Empty line required after class declaration");
		assertNoMsg(new EmptyLinesCheck(), TEST11);
		assertNoMsg(new EmptyLinesCheck(), TEST12);
	}

	@Test
	public function testRequireEmptyLineAfterInterface() {
		assertMsg(new EmptyLinesCheck(), TEST13, "Empty line required after interface declaration");
		assertNoMsg(new EmptyLinesCheck(), TEST14);
		assertNoMsg(new EmptyLinesCheck(), TEST15);
	}

	@Test
	public function testRequireEmptyLineAfterAbstract() {
		assertMsg(new EmptyLinesCheck(), TEST16, "Empty line required after abstract declaration");
		assertNoMsg(new EmptyLinesCheck(), TEST17);
		assertNoMsg(new EmptyLinesCheck(), TEST18);
	}
}

@:enum
abstract EmptyLinesCheckTests(String) to String {
	var TEST1 = "
	class Test {

		var a:Int;

		var b:String = '\\\\' + \"\\\\\";


	}";

	var TEST2 =
	"class Test {

		public function new() {

			var b:Int;

			var c:String = ' multistring



			';

			var d:String = ' multistring; \"



			';

			var e:String = ' multistring; \"\\'

				var t=1;



				var s=\\'\\';



			';

		}
	}";

	var TEST3 =
	"class Test {

		public function new() {

			var b:Int;


		}
	}";

	var TEST4 =
	"class Test {

		// comments (with text before)

		public function new() {
			var b:Int;
		}
	}";

	var TEST5 =
	"class Test {

// comments (with no text before)

		var a:Int;
	}";

	var TEST6 =
	"class Test {

		/**
		 *comments
		 */

		var a:Int;
	}";

	var TEST7 =
	"class Test {

		/**
		 *comments
		 */

		public function new() {
			var b:Int;
		}
	}";

	var TEST8 = "
	package pack;
	using StringTools;

	class Test {}";

	var TEST9 = "
	package pack;

	using StringTools;

	class Test {}";

	var TEST10 =
	"class Test {
		public function new() {
			var b:Int;
		}
	}";

	var TEST11 =
	"class Test {

		public function new() {
			var b:Int;
		}
	}";

	var TEST12 =
	"class Test
	{

		public function new() {
			var b:Int;
		}
	}";

	var TEST13 =
	"interface Test {
		var b:Int;
	}";

	var TEST14 =
	"interface Test {

		function test():Void;

	}";

	var TEST15 =
	"interface Test
	{

		function test():Void;
	}";

	var TEST16 =
	"abstract Test(Int) {
		var A = 10;
	}";

	var TEST17 =
	"abstract Test(Int) {

		var A = 10;

	}";

	var TEST18 =
	"abstract Test(Int)
	{
		var A = 10;
	}";
}