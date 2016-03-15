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
	static inline var MSG_SAME_PACKAGE_IMPORT:String = "Detected import checkstyle.checks.Checker from same package checkstyle.checks";
	static inline var MSG_UNUSED_TYPEMAP:String = "Unused import checkstyle.checks.Checker detected";

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

	public function testSamePackageImport() {
		var check = new UnusedImportCheck();
		assertMsg(check, SAME_PACKAGE_IMPORT, MSG_SAME_PACKAGE_IMPORT);
	}

	public function testTypeMap() {
		var check = new UnusedImportCheck();
		assertMsg(check, SAME_PACKAGE_TYPE_MAP, MSG_SAME_PACKAGE_IMPORT);
		assertMsg(check, IMPORT_TYPE_MAP, MSG_UNUSED_TYPEMAP);
		assertMsg(check, UNUSED_IMPORT_TYPE_MAP, MSG_UNUSED_TYPEMAP);

		check.moduleTypeMap = {
			"checkstyle.checks.Checker": [
				"CheckBase",
				"UnusedImportCheck"
			]
		};
		assertNoMsg(check, SAME_PACKAGE_TYPE_MAP);
		assertNoMsg(check, IMPORT_TYPE_MAP);
		assertMsg(check, UNUSED_IMPORT_TYPE_MAP, MSG_UNUSED_TYPEMAP);
	}
}

@:enum
abstract UnusedImportCheckTests(String) to String {
	var ALL_IMPORTS_USED = "
	package checkstyle.test;

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
	package checkstyle.test;

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
	package checkstyle.test;

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
	package checkstyle.test;

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
	package checkstyle.test;

	import String;

	abstractAndClass Check {

		public function new() {
		}
	}";

	var IMPORT_BASE_CLASS = "
	package checkstyle.test;

	import haxe.checkstyle.Base;
	import checkstyle.Interface;

	class Check extends Base implements Interface {

		public function new() {}
	}";

	var IMPORT_AS = "
	package checkstyle.test;

	import haxe.checkstyle.Check as Base;
	import haxe.checkstyle.Check2 in Base2;

	class Test extends Base implements Base2 {}";

	var UNUSED_IMPORT_AS = "
	package checkstyle.test;

	import haxe.checkstyle.Check as Base;

	class Test {}";

	var UNUSED_IMPORT_IN = "
	package checkstyle.test;

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

	var SAME_PACKAGE_IMPORT = "
	package checkstyle.checks;

	import checkstyle.checks.Checker;
	import checkstyle.checks.imports.UnusedImportCheck;

	abstractAndClass Main {

		static function main():Checker {
			return new UnusedImportCheck ();
		}
	}";

	var SAME_PACKAGE_TYPE_MAP = "
	package checkstyle.checks;

	import checkstyle.checks.Checker;

	abstractAndClass Main {

		static function main():Check {
			return new UnusedImportCheck ();
		}
	}";

	var IMPORT_TYPE_MAP = "
	package checkstyle.test;

	import checkstyle.checks.Checker;

	abstractAndClass Main {

		static function main():CheckBase {
			return new UnusedImportCheck ();
		}
	}";

	var UNUSED_IMPORT_TYPE_MAP = "
	package checkstyle.test;

	import checkstyle.checks.Checker;

	abstractAndClass Main {

		static function main():Check {
			return new OtherCheck ();
		}
	}";
}