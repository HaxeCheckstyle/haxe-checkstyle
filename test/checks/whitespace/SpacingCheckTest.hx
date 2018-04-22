package checks.whitespace;

import checkstyle.checks.whitespace.SpacingCheck;
import checkstyle.checks.Directive;

class SpacingCheckTest extends CheckTestCase<SpacingCheckTests> {

	@Test
	public function testIfShouldContainSpace() {
		assertMsg(new SpacingCheck(), TEST1A, 'No space between "if" and "("');
		assertNoMsg(new SpacingCheck(), TEST1B);
	}

	@Test
	public function testIfShouldNotContainSpace() {
		var check = new SpacingCheck();
		check.spaceIfCondition = Directive.SHOULD_NOT;

		assertMsg(check, TEST1B, 'Space between "if" and "("');
		assertNoMsg(check, TEST1A);
	}

	@Test
	public function testBinaryOperator() {
		assertMsg(new SpacingCheck(), TEST2, 'No space around "+"');
	}

	@Test
	public function testUnaryOperator() {
		assertMsg(new SpacingCheck(), TEST3, 'Space around "++"');
	}

	@Test
	public function testRangeOperator() {
		var check = new SpacingCheck();
		assertNoMsg(check, TEST4B);

		check.ignoreRangeOperator = false;
		assertMsg(check, TEST4B, 'No space around "..."');
	}

	@Test
	public function testForShouldContainSpace() {
		assertMsg(new SpacingCheck(), TEST4A, 'No space between "for" and "("');
		assertNoMsg(new SpacingCheck(), TEST4B);
	}

	@Test
	public function testForShouldNotContainSpace() {
		var check = new SpacingCheck();
		check.spaceForLoop = Directive.SHOULD_NOT;

		assertMsg(check, TEST4B, 'Space between "for" and "("');
		assertNoMsg(check, TEST4A);
	}

	@Test
	public function testWhileShouldContainSpace() {
		assertMsg(new SpacingCheck(), TEST5A, 'No space between "while" and "("');
		assertNoMsg(new SpacingCheck(), TEST5B);
	}

	@Test
	public function testWhileShouldNotContainSpace() {
		var check = new SpacingCheck();
		check.spaceWhileLoop = Directive.SHOULD_NOT;

		assertMsg(check, TEST5B, 'Space between "while" and "("');
		assertNoMsg(check, TEST5A);
	}

	@Test
	public function testSwitchShouldContainSpace() {
		assertMsg(new SpacingCheck(), TEST6A, 'No space between "switch" and "("');
		assertNoMsg(new SpacingCheck(), TEST6B);
	}

	@Test
	public function testSwitchShouldNotContainSpace() {
		var check = new SpacingCheck();
		check.spaceSwitchCase = Directive.SHOULD_NOT;

		assertMsg(check, TEST6B, 'Space between "switch" and "("');
		assertNoMsg(check, TEST6A);
	}

	@Test
	public function testCatchShouldContainSpace() {
		assertMsg(new SpacingCheck(), TEST7A, 'No space between "catch" and "("');
		assertNoMsg(new SpacingCheck(), TEST7B);
	}

	@Test
	public function testCatchShouldNotContainSpace() {
		var check = new SpacingCheck();
		check.spaceCatch = Directive.SHOULD_NOT;

		assertMsg(check, TEST7B, 'Space between "catch" and "("');
		assertNoMsg(check, TEST7A);
	}

	@Test
	public function testMultilineIf() {
		var check = new SpacingCheck();
		assertMsg(check, TEST8, 'No space between "if" and "("');

		check.spaceIfCondition = Directive.SHOULD_NOT;
		assertMsg(check, TEST8, 'Space between "if" and "("');
	}
}

@:enum
abstract SpacingCheckTests(String) to String {
	var TEST1A = "
	class Test {
		public function test() {
			if(true) {}
		}
	}";

	var TEST1B = "
	class Test {
		public function test() {
			if (true) {}
		}
	}";

	var TEST2 = "
	class Test {
		public function test() {
			var a = a+1;
		}
	}";

	var TEST3 = "
	class Test {
		public function test() {
			var a = a ++;
		}
	}";

	var TEST4A = "
	class Test {
		public function test() {
			for(i in 0...10) {

			}
		}
	}";

	var TEST4B = "
	class Test {
		public function test() {
			for (i in 0...10) {

			}
		}
	}";

	var TEST5A = "
	class Test {
		public function test() {
			while(true) {}
		}
	}";

	var TEST5B = "
	class Test {
		public function test() {
			while (true) {}
		}
	}";

	var TEST6A = "
	class Test {
		public function test() {
			switch(0) {
				case 1:
				case _:
			}
		}
	}";

	var TEST6B = "
	class Test {
		public function test() {
			switch (0) {
				case 1:
				case _:
			}
		}
	}";

	var TEST7A = "
	class Test {
		public function test() {
			try {}
			catch(e:Dynamic) {}
		}
	}";

	var TEST7B = "
	class Test {
		public function test() {
			try {}
			catch (e:Dynamic) {}
		}
	}";

	var TEST8 = "
	class Test {
		public function test() {
			if(
				true
				&& true
				|| false
			) {}

			if (
				true
				&& true
				|| false
			) {}
		}
	}";
}