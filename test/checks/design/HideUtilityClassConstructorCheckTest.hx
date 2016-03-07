package checks.design;

import checkstyle.checks.design.HideUtilityClassConstructorCheck;

class HideUtilityClassConstructorCheckTest extends CheckTestCase {

	public function testWithConstructor() {
		assertMsg(new HideUtilityClassConstructorCheck(), HideUtilityClassConstructorCheckTests.TEST1, "Utility classes should not have a constructor");
	}

	public function testWithoutConstructor() {
		assertNoMsg(new HideUtilityClassConstructorCheck(), HideUtilityClassConstructorCheckTests.TEST2);
	}
}

class HideUtilityClassConstructorCheckTests {
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
}