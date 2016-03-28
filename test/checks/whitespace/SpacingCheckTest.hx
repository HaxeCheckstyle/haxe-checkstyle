package checks.whitespace;

import checkstyle.checks.whitespace.SpacingCheck;

class SpacingCheckTest extends CheckTestCase<SpacingCheckTests> {

	public function testIf() {
		assertMsg(new SpacingCheck(), TEST1A, 'No space between "if" and "("');
		assertNoMsg(new SpacingCheck(), TEST1B);
	}

	public function testBinaryOperator() {
		assertMsg(new SpacingCheck(), TEST2, 'No space around "+"');
	}

	public function testUnaryOperator() {
		assertMsg(new SpacingCheck(), TEST3, 'Space around "++"');
	}

	public function testFor() {
		assertMsg(new SpacingCheck(), TEST4A, 'No space between "for" and "("');
		assertNoMsg(new SpacingCheck(), TEST4B);
	}

	public function testWhile() {
		assertMsg(new SpacingCheck(), TEST5A, 'No space between "while" and "("');
		assertNoMsg(new SpacingCheck(), TEST5B);
	}

	public function testSwitch() {
		assertMsg(new SpacingCheck(), TEST6A, 'No space between "switch" and "("');
		assertNoMsg(new SpacingCheck(), TEST6B);
	}

	public function testCatch() {
		assertMsg(new SpacingCheck(), TEST7A, 'No space between "catch" and "("');
		assertNoMsg(new SpacingCheck(), TEST7B);
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

	var TEST2 =
	"class Test {
		public function test() {
			var a = a+1;
		}
	}";

	var TEST3 =
	"class Test {
		public function test() {
			var a = a ++;
		}
	}";

	var TEST4A =
	"class Test {
		public function test() {
			for(i in 0...10) {

			}
		}
	}";

	var TEST4B =
	"class Test {
		public function test() {
			for (i in 0...10) {

			}
		}
	}";

	var TEST5A =
	"class Test {
		public function test() {
			while(true) {}
		}
	}";

	var TEST5B =
	"class Test {
		public function test() {
			while (true) {}
		}
	}";

	var TEST6A =
	"class Test {
		public function test() {
			switch(0) {
				case 1:
				case _:
			}
		}
	}";

	var TEST6B =
	"class Test {
		public function test() {
			switch (0) {
				case 1:
				case _:
			}
		}
	}";

	var TEST7A =
	"class Test {
		public function test() {
			try {}
			catch(e:Dynamic) {}
		}
	}";

	var TEST7B =
	"class Test {
		public function test() {
			try {}
			catch (e:Dynamic) {}
		}
	}";
}