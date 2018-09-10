package checks.whitespace;

import checkstyle.checks.whitespace.ArrayAccessCheck;

class ArrayAccessCheckTest extends CheckTestCase<ArrayAccessCheckTests> {
	@Test
	public function testSpaceBefore() {
		assertMsg(new ArrayAccessCheck(), TEST1, "Space between array and [");
	}

	@Test
	public function testSpaceInside() {
		var check = new ArrayAccessCheck();
		assertMsg(check, TEST2, "Space between [ and index");
		assertMsg(check, TEST3, "Space between index and ]");
		assertMsg(check, TEST4, "Space between index and ]");
	}

	@Test
	public function testAllowSpaceInside() {
		var check = new ArrayAccessCheck();
		check.spaceBefore = true;
		check.spaceInside = true;
		assertNoMsg(check, TEST1);
		assertNoMsg(check, TEST2);
		assertNoMsg(check, TEST3);
		assertNoMsg(check, TEST4);
	}

	@Test
	public function testCorrectUsage() {
		var check = new ArrayAccessCheck();
		assertNoMsg(check, TEST5);
	}
}

@:enum
abstract ArrayAccessCheckTests(String) to String {
	var TEST1 = "
	class Test {

		var a:Array<Int> = [];

		function a() {
			a [0] = 1;
		}
	}";
	var TEST2 = "
	class Test {

		var a:Array<Int> = [];

		function a() {
			a[ 0] = 1;
		}
	}";
	var TEST3 = "
	class Test {

		var a:Array<Int> = [];

		function a() {
			a[0 ] = 1;
		}
	}";
	var TEST4 = "
	class Test {

		var a:Array<Int> = [];

		function a() {
			a[ 0 ] = 1;
		}
	}";
	var TEST5 = "
	class Test {

		var a:Array<Int> = [];

		function a() {
			a[0] = 1;
		}
	}";
}