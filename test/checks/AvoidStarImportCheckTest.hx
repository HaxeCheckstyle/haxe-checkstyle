package checks;

import checkstyle.checks.AvoidStarImportCheck;

class AvoidStarImportCheckTest extends CheckTestCase {

	public function testNoStarImport() {
		var check = new AvoidStarImportCheck();
		assertMsg(check, AvoidStarImportCheckTests.IMPORT, '');
	}

	public function testStarImport() {
		var check = new AvoidStarImportCheck();
		assertMsg(check, AvoidStarImportCheckTests.STAR_IMPORT, 'Import line uses a star (.*) import - consider using full type names');
	}
}

class AvoidStarImportCheckTests {
	public static inline var IMPORT:String = "
	package haxe.checkstyle;

	import haxe.checkstyle.Check;
	import haxe.checkstyle.Check2;
	import haxe.checkstyle.Check3;

	using haxe.checkstyle.Check;

	class Test {
		public function new() {}
	}";

	public static inline var STAR_IMPORT:String = "
	package haxe.checkstyle;

	import haxe.checkstyle.*;
	import haxe.checkstyle.Check2;
	import haxe.checkstyle.Check3;

	using haxe.checkstyle.Check;

	class Test {
		public function new() {}
	}";
}