package checkstyle.checks.naming;

class FileNameCaseCheckTest extends CheckTestCase<FileNameCaseCheckTests> {
	@Test
	public function testCorrectNaming() {
		var check = new FileNameCaseCheck();
		assertNoMsg(check, IMPORT, "import.hx");
		assertNoMsg(check, TYPES, "Test.hx");
		assertNoMsg(check, TYPES, "ITest.hx");
		assertNoMsg(check, TYPES, "Test2.hx");
		assertNoMsg(check, TYPES, "Test3.hx");
	}

	@Test
	public function testIncorrectImport() {
		var check = new FileNameCaseCheck();
		assertMsg(check, IMPORT, '"Import.hx" contains no types - consider renaming to "import.hx"', "Import.hx");
		assertMsg(check, TYPES, '"import.hx" contains types', "import.hx");
	}

	@Test
	public function testModuleWithNoTypes() {
		var check = new FileNameCaseCheck();
		assertMsg(check, IMPORT, '"Main.hx" defines no type with name "Main"', "Main.hx");
	}

	@Test
	public function testIncorrectCase() {
		var check = new FileNameCaseCheck();

		assertMessages(check, TYPES, [
			'"TeSt.hx" defines type "Test" using different case',
			'"TeSt.hx" defines no type with name "TeSt"'
		], "TeSt.hx");

		assertMessages(check, TYPES, [
			'"Itest.hx" defines type "ITest" using different case',
			'"Itest.hx" defines no type with name "Itest"'
		], "Itest.hx");
	}
}

enum abstract FileNameCaseCheckTests(String) to String {
	var IMPORT = "
	import haxe.io.Path;
	import checkstyle.checks.Check;

	using StringTools;
	";

	var TYPES = "
	class Test {
		public var a:Int;
		private var b:Int;
		static var COUNT:Int = 1;
		static inline var COUNT2:Int = 1;
		var count5:Int = 1;
	}

	interface ITest {

	}

	enum Test2 {
		count;
		a;
	}

	typedef Test3 = {
		var count1:Int;
		var count2:String;
	}";
}