package checks.whitespace;

import checkstyle.checks.whitespace.SpacingCheck;

class SpacingCheckTest extends CheckTestCase {

	public function testIf() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST1A, 'No space between if and (');
		assertNoMsg(new SpacingCheck(), SpacingTests.TEST1B);
	}

	public function testBinaryOperator() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST2, 'No space around +');
	}

	public function testUnaryOperator() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST3, 'Space around ++');
	}

	public function testFor() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST4A, 'No space between for and (');
		assertNoMsg(new SpacingCheck(), SpacingTests.TEST4B);
	}

	public function testWhile() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST5A, 'No space between while and (');
		assertNoMsg(new SpacingCheck(), SpacingTests.TEST5B);
	}

	public function testSwitch() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST6A, 'No space between switch and (');
		assertNoMsg(new SpacingCheck(), SpacingTests.TEST6B);
	}
}

class SpacingTests {
	public static inline var TEST1A:String = "
	class Test {
		public function test() {
			if(true) {}
		}
	}";

	public static inline var TEST1B:String = "
	class Test {
		public function test() {
			if (true) {}
		}
	}";

	public static inline var TEST2:String =
	"class Test {
		public function test() {
			var a = a+1;
		}
	}";

	public static inline var TEST3:String =
	"class Test {
		public function test() {
			var a = a ++;
		}
	}";

	public static inline var TEST4A:String =
	"class Test {
		public function test() {
			for(i in 0...10) {
			
			}
		}
	}";

	public static inline var TEST4B:String =
	"class Test {
		public function test() {
			for (i in 0...10) {
			
			}
		}
	}";

	public static inline var TEST5A:String =
	"class Test {
		public function test() {
			while(true) {}
		}
	}";

	public static inline var TEST5B:String =
	"class Test {
		public function test() {
			while (true) {}
		}
	}";

	public static inline var TEST6A:String =
	"class Test {
		public function test() {
			switch(0) {
				case 1:
				case _:
			}
		}
	}";

	public static inline var TEST6B:String =
	"class Test {
		public function test() {
			switch (0) {
				case 1:
				case _:
			}
		}
	}";
}