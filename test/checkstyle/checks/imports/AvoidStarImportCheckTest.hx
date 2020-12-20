package checkstyle.checks.imports;

class AvoidStarImportCheckTest extends CheckTestCase<AvoidStarImportCheckTests> {
	static inline var MSG_STAR_IMPORT:String = 'Using the ".*" form of import should be avoided';

	@Test
	public function testNoStarImport() {
		var check = new AvoidStarImportCheck();
		assertNoMsg(check, IMPORT);
	}

	@Test
	public function testStarImport() {
		var check = new AvoidStarImportCheck();
		assertMsg(check, STAR_IMPORT, MSG_STAR_IMPORT);
		assertMsg(check, CONDITIONAL_STAR_IMPORT_ISSUE_160, MSG_STAR_IMPORT);
		assertMsg(check, CONDITIONAL_ELSE_STAR_IMPORT, MSG_STAR_IMPORT);
		assertMessages(check, CONDITIONAL_ELSEIF_STAR_IMPORT, [MSG_STAR_IMPORT, MSG_STAR_IMPORT, MSG_STAR_IMPORT]);
	}
}

enum abstract AvoidStarImportCheckTests(String) to String {
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
	var CONDITIONAL_STAR_IMPORT_ISSUE_160 = "
	#if macro
		import haxe.macro.*;
	#end";
	var CONDITIONAL_ELSEIF_STAR_IMPORT = "
	#if macro
		import haxe.macro.Type;
	#elseif neko
		import haxe.macro.*;
	#elseif neko
		import haxe.macro.*;
	#else
		#if linux
			import haxe.macro.Type;
		#else
			import haxe.macro.*;
		#end
	#end
	import haxe.macro.Type;";
	var CONDITIONAL_ELSE_STAR_IMPORT = "
	#if macro
		import haxe.macro.Type;
	#else
		import haxe.macro.*;
	#end
	import haxe.macro.Type;";
}