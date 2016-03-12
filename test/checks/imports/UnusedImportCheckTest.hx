package checks.imports;

import checkstyle.checks.imports.UnusedImportCheck;

class UnusedImportCheckTest extends CheckTestCase<UnusedImportCheckTests> {

	static inline var MSG_UNUSED:String = "Unused import haxe.checkstyle.Check3 detected";
	static inline var MSG_NAME_REUSED:String = "Unused import haxe.checkstyle.Check detected";
	static inline var MSG_DUPLICATE:String = "Duplicate import haxe.checkstyle.Check2 detected";
	static inline var MSG_TOP_LEVEL:String = "Unnecessary toplevel import String detected";
	static inline var MSG_UNUSED_AS:String = "Unused import haxe.checkstyle.Check as Base detected";
	static inline var MSG_UNUSED_IN:String = "Unused import haxe.checkstyle.Check in Base detected";
	static inline var MSG_UNUSED_IN_STATIC:String = "Unused import String.fromCharCode in f detected";

	public function testCorrectImport() {
		var check = new UnusedImportCheck();
		assertNoMsg(check, ALL_IMPORTS_USED);
		assertNoMsg(check, IMPORT_BASE_CLASS);
		assertNoMsg(check, IMPORT_AS);
		assertNoMsg(check, IMPORT_IN_STATIC_FUNC);
	}

	public function testUnusedImport() {
		var check = new UnusedImportCheck();
		assertMsg(check, IMPORT_NOT_USED, MSG_UNUSED);
		assertMsg(check, DUPLICATE_IMPORT, MSG_DUPLICATE);
		assertMsg(check, IMPORT_NAME_REUSED, MSG_NAME_REUSED);
		assertMsg(check, TOP_LEVEL_IMPORT, MSG_TOP_LEVEL);
		assertMsg(check, UNUSED_IMPORT_AS, MSG_UNUSED_AS);
		assertMsg(check, UNUSED_IMPORT_IN, MSG_UNUSED_IN);
		assertMsg(check, UNUSED_IMPORT_IN_STATIC_FUNC, MSG_UNUSED_IN_STATIC);
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

		public function new() {}
	}";

	var IMPORT_AS = "
	package haxe.test;

	import haxe.checkstyle.Check as Base;
	import haxe.checkstyle.Check2 in Base2;

	class Test extends Base implements Base2 {}";

	var UNUSED_IMPORT_AS = "
	package haxe.test;

	import haxe.checkstyle.Check as Base;

	class Test {}";

	var UNUSED_IMPORT_IN = "
	package haxe.test;

	import haxe.checkstyle.Check in Base;

	abstractAndClass Test {}";

	var IMPORT_IN_STATIC_FUNC = "
	import String.fromCharCode in f;

	abstractAndClass Main {

		static function main() {
			var c1 = f(65);
		}
	}";

	var UNUSED_IMPORT_IN_STATIC_FUNC = "
	import String.fromCharCode in f;

	abstractAndClass Main {

		static function main() {}
	}";
}