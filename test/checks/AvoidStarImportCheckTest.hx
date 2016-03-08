package checks;

import checkstyle.checks.AvoidStarImportCheck;

class AvoidStarImportCheckTest extends CheckTestCase<AvoidStarImportCheckTests> {

	public function testNoStarImport() {
		var check = new AvoidStarImportCheck();
		assertNoMsg(check, IMPORT);
	}

	public function testStarImport() {
		var check = new AvoidStarImportCheck();
		assertMsg(check, STAR_IMPORT, 'Import line uses a star (.*) import - consider using full type names');
	}
}

@:enum
abstract AvoidStarImportCheckTests(String) to String {
	var IMPORT = "
	package haxe.checkstyle;

	import haxe.checkstyle.Check;
	import haxe.checkstyle.Check2;
	import haxe.checkstyle.Check3;

	using haxe.checkstyle.Check;

	class Test {
		public function new() {}
	}";

	var STAR_IMPORT = "
	package haxe.checkstyle;

	import haxe.checkstyle.*;
	import haxe.checkstyle.Check2;
	import haxe.checkstyle.Check3;

	using haxe.checkstyle.Check;

	class Test {
		public function new() {}
	}";
}