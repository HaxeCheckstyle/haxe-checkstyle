package checks.imports;

import checkstyle.checks.imports.UnusedImportCheck;

class UnusedImportCheckTest extends CheckTestCase<UnusedImportCheckTests> {

	static inline var MSG_UNUSED:String = "Unused import haxe.checkstyle.Check3 detected";
	static inline var MSG_NAME_REUSED:String = "Unused import haxe.checkstyle.Check detected";
	static inline var MSG_DUPLICATE:String = "Duplicate import haxe.checkstyle.Check2 detected";
	static inline var MSG_TOP_LEVEL:String = "Top level import String detected";

	public function testCorrectImport() {
		var check = new UnusedImportCheck();
		assertNoMsg(check, ALL_IMPORTS_USED);
		assertNoMsg(check, IMPORT_BASE_CLASS);
	}

	public function testUnusedImport() {
		var check = new UnusedImportCheck();
		assertMsg(check, IMPORT_NOT_USED, MSG_UNUSED);
		assertMsg(check, DUPLICATE_IMPORT, MSG_DUPLICATE);
		assertMsg(check, IMPORT_NAME_REUSED, MSG_NAME_REUSED);
		assertMsg(check, TOP_LEVEL_IMPORT, MSG_TOP_LEVEL);
	}
}

@:enum
abstract UnusedImportCheckTests(String) to String {
	var ALL_IMPORTS_USED = "
	package haxe.checkstyle;

	import haxe.checkstyle.Check;
	import haxe.checkstyle.Check2;
	import haxe.checkstyle.Check3;
	import haxe.checkstyle.sub.*;

	abstractAndClass Test {

		public function new() {
			new Check();
			new Check2();
			Check3.test();
			new Check4();
		}
	}";

	var IMPORT_NOT_USED = "
	package haxe.checkstyle;

	import haxe.checkstyle.Check;
	import haxe.checkstyle.Check2;
	import haxe.checkstyle.Check3;

	abstractAndClass Test {

		public function new() {
			new Check();
			Check2.test();
		}
	}";

	var DUPLICATE_IMPORT = "
	package haxe.checkstyle;

	import haxe.checkstyle.Check;
	import haxe.checkstyle.Check2;
	import haxe.checkstyle.Check2;

	abstractAndClass Test {

		public function new() {
			new Check();
			Check2.test();
		}
	}";

	var IMPORT_NAME_REUSED = "
	package haxe.test;

	import haxe.checkstyle.Check;

	abstractAndClass Check {

		public function new() {
			otherpackge.Check.test();
		}
	}

	interface Check {
		function test();
	}

	enum Check {
		A;
		B;
	}

	typedef Check = Dynamic; ";

	var TOP_LEVEL_IMPORT = "
	package haxe.test;

	import String;

	abstractAndClass Check {

		public function new() {
		}
	}";

	var IMPORT_BASE_CLASS = "
	package haxe.test;

	import haxe.checkstyle.Base;
	import checkstyle.Interface;

	class Check extends Base implements Interface {

		public function new() {
		}
	}";
}