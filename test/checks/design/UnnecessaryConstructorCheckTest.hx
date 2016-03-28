package checks.design;

import checkstyle.checks.design.UnnecessaryConstructorCheck;

class UnnecessaryConstructorCheckTest extends CheckTestCase<UnnecessaryConstructorCheckTests> {

	public function testWithConstructor() {
		assertMsg(new UnnecessaryConstructorCheck(), TEST1, "Unnecessary constructor found");
	}

	public function testWithoutConstructor() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST2);
	}

	public function testWithConstructorAndInstanceVar() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST3);
	}

	public function testWithConstructorAndInstanceFunction() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST4);
	}

	public function testJustVarsWithConstructor() {
		assertMsg(new UnnecessaryConstructorCheck(), TEST5, "Unnecessary constructor found");
	}

	public function testJustWithConstructor() {
		assertNoMsg(new UnnecessaryConstructorCheck(), TEST6);
	}
}

@:enum
abstract UnnecessaryConstructorCheckTests(String) to String {
	var TEST1 = "
	class Test {
		public function new() {}

		static var a:Int = 1;
		static inline var b:Int = 1;
		public static function walkFile() {}
		static function test() {}
	}";

	var TEST2 = "
	class Test {
		static var a:Int = 1;
		static inline var b:Int = 1;
		public static function walkFile() {}
		static function test() {}
	}";

	var TEST3 = "
	class Test {
		var loc:Float;
		static var a:Int = 1;
		static inline var b:Int = 1;

		public function new() {}

		public static function walkFile() {}

		static function test() {}
	}";

	var TEST4 = "
	class Test {
		var loc:Float;
		static var a:Int = 1;
		static inline var b:Int = 1;

		public function new() {}

		public static function walkFile() {}

		static function test() {}

		public function test2(){}
	}";

	var TEST5 = "
	class Test {
		public function new() {}

		static var a:Int = 1;
		static inline var b:Int = 1;
	}";

	var TEST6 = "
	class Test {
		public function new() {}
	}";
}