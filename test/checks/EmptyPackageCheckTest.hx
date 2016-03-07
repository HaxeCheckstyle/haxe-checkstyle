package checks;

import checkstyle.checks.EmptyPackageCheck;

class EmptyPackageCheckTest extends CheckTestCase {

	public function testEmptyPackage() {
		assertMsg(new EmptyPackageCheck(), EmptyPackageCheckTests.TEST1, "Found empty package");
	}

	public function testCorrectPackage() {
		assertNoMsg(new EmptyPackageCheck(), EmptyPackageCheckTests.TEST2);
	}
}

class EmptyPackageCheckTests {
	public static inline var TEST1:String = "
	package;

	class Test {
		public function new() {}
	}";

	public static inline var TEST2:String = "
	package checks.test;

	class Test {
		public function new() {}
	}";
}