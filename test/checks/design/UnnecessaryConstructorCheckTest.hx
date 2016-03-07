package checks.design;

import checkstyle.checks.design.UnnecessaryConstructorCheck;

class UnnecessaryConstructorCheckTest extends CheckTestCase {

	public function testWithConstructor() {
		assertMsg(new UnnecessaryConstructorCheck(), UnnecessaryConstructorCheckTests.TEST1, "Unnecessary constructor found");
	}

	public function testWithoutConstructor() {
		assertNoMsg(new UnnecessaryConstructorCheck(), UnnecessaryConstructorCheckTests.TEST2);
	}

	public function testWithConstructorAndInstanceVar() {
		assertNoMsg(new UnnecessaryConstructorCheck(), UnnecessaryConstructorCheckTests.TEST3);
	}

	public function testWithConstructorAndInstanceFunction() {
		assertNoMsg(new UnnecessaryConstructorCheck(), UnnecessaryConstructorCheckTests.TEST4);
	}

	public function testJustVarsWithConstructor() {
		assertMsg(new UnnecessaryConstructorCheck(), UnnecessaryConstructorCheckTests.TEST5, "Unnecessary constructor found");
	}

	public function testJustWithConstructor() {
		assertNoMsg(new UnnecessaryConstructorCheck(), UnnecessaryConstructorCheckTests.TEST6);
	}
}

class UnnecessaryConstructorCheckTests {
	public static inline var TEST1:String = "
	class Test {
		public function new() {}

		static var a:Int = 1;
		static inline var b:Int = 1;
		public static function walkFile() {}
		static function test() {}
	}";

	public static inline var TEST2:String = "
	class Test {
		static var a:Int = 1;
		static inline var b:Int = 1;
		public static function walkFile() {}
		static function test() {}
	}";

	public static inline var TEST3:String = "
	class Test {
		var loc:Float;
		static var a:Int = 1;
		static inline var b:Int = 1;

		public function new() {}

		public static function walkFile() {}

		static function test() {}
	}";

	public static inline var TEST4:String = "
	class Test {
		var loc:Float;
		static var a:Int = 1;
		static inline var b:Int = 1;

		public function new() {}

		public static function walkFile() {}

		static function test() {}

		public function test2(){}
	}";

	public static inline var TEST5:String = "
	class Test {
		public function new() {}

		static var a:Int = 1;
		static inline var b:Int = 1;
	}";

	public static inline var TEST6:String = "
	class Test {
		public function new() {}
	}";
}