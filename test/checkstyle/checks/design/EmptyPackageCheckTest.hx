package checkstyle.checks.design;

class EmptyPackageCheckTest extends CheckTestCase<EmptyPackageCheckTests> {
	@Test
	public function testEmptyPackage() {
		assertMsg(new EmptyPackageCheck(), TEST1, "Found empty package");
		assertNoMsg(new EmptyPackageCheck(), TEST3);
	}

	@Test
	public function testCorrectPackage() {
		assertNoMsg(new EmptyPackageCheck(), TEST2);
	}

	@Test
	public function testEnforceEmptyPackage() {
		var check = new EmptyPackageCheck();
		check.enforceEmptyPackage = true;

		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertMsg(check, TEST3, "Missing package declaration");
	}
}

enum abstract EmptyPackageCheckTests(String) to String {
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
	var TEST3 = "
	class Test {
		public function new() {}
	}";
}