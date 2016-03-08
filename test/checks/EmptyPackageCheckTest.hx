package checks;

import checkstyle.checks.EmptyPackageCheck;

class EmptyPackageCheckTest extends CheckTestCase<EmptyPackageCheckTests> {

	public function testEmptyPackage() {
		assertMsg(new EmptyPackageCheck(), TEST1, "Found empty package");
	}

	public function testCorrectPackage() {
		assertNoMsg(new EmptyPackageCheck(), TEST2);
	}
}

@:enum
abstract EmptyPackageCheckTests(String) to String {
	var TEST1 = "
	package;

	class Test {
		public function new() {}
	}";

	var TEST2 = "
	package checks.test;

	class Test {
		public function new() {}
	}";
}