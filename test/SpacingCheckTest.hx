import checkstyle.checks.SpacingCheck;

class SpacingCheckTest extends CheckTestCase {

	public function testIf() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST1a, 'No space between if and (');
		assertMsg(new SpacingCheck(), SpacingTests.TEST1b, '');
	}

	public function testBinaryOperator() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST2, 'No space around +');
	}

	public function testUnaryOperator() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST3, 'Space around ++');
	}

	public function testFor() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST4a, 'No space between for and (');
		assertMsg(new SpacingCheck(), SpacingTests.TEST4b, '');
	}

	public function testWhile() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST5a, 'No space between while and (');
		assertMsg(new SpacingCheck(), SpacingTests.TEST5b, '');
	}

	public function testSwitch() {
		assertMsg(new SpacingCheck(), SpacingTests.TEST6a, 'No space between switch and (');
		assertMsg(new SpacingCheck(), SpacingTests.TEST6b, '');
	}
}

class SpacingTests {
	public static inline var TEST1a:String = "
	class Test {
		public function test() {
			if(true) {}
		}
	}";

	public static inline var TEST1b:String = "
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

	public static inline var TEST4a:String =
	"class Test {
		public function test() {
			for(i in 0...10) {
			
			}
		}
	}";

	public static inline var TEST4b:String =
	"class Test {
		public function test() {
			for (i in 0...10) {
			
			}
		}
	}";

	public static inline var TEST5a:String =
	"class Test {
		public function test() {
			while(true) {}
		}
	}";

	public static inline var TEST5b:String =
	"class Test {
		public function test() {
			while (true) {}
		}
	}";

	public static inline var TEST6a:String =
	"class Test {
		public function test() {
			switch(0) {
				case 1:
				case _:
			}
		}
	}";

	public static inline var TEST6b:String =
	"class Test {
		public function test() {
			switch (0) {
				case 1:
				case _:
			}
		}
	}";
}