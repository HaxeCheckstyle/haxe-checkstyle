package checks.coding;

import checkstyle.checks.coding.MultipleVariableDeclarationsCheck;

class MultipleVariableDeclarationsCheckTest extends CheckTestCase {

	public function testMulitiVarsStatement() {
		assertMsg(new MultipleVariableDeclarationsCheck(), MultipleVariableDeclarationsCheckTests.TEST1, 'Each variable declaration must be in its own statement');
		assertMsg(new MultipleVariableDeclarationsCheck(), MultipleVariableDeclarationsCheckTests.TEST2, 'Each variable declaration must be in its own statement');
	}

	public function testMulitiVarsInOneLine() {
		assertMsg(new MultipleVariableDeclarationsCheck(), MultipleVariableDeclarationsCheckTests.TEST3, 'Only one variable definition per line allowed');
	}

	public function testCorrectVariables() {
		assertNoMsg(new MultipleVariableDeclarationsCheck(), MultipleVariableDeclarationsCheckTests.TEST4);
	}

	public function testSuppressWarnings() {
		assertNoMsg(new MultipleVariableDeclarationsCheck(), MultipleVariableDeclarationsCheckTests.TEST5);
		assertNoMsg(new MultipleVariableDeclarationsCheck(), MultipleVariableDeclarationsCheckTests.TEST6);
	}
}

class MultipleVariableDeclarationsCheckTests {
	public static inline var TEST1:String = "
	abstractAndClass Test {
		function a() {
			var d,e = 2;
		}
	}";

	public static inline var TEST2:String = "
	abstractAndClass Test {
		function a() {
			var d,e,f;
		}
	}";

	public static inline var TEST3:String = "
	abstractAndClass Test {
		function a() {
			var d; var e;
		}
	}";

	public static inline var TEST4:String = "
	abstractAndClass Test {
		function a() {
			var d;
			var e = 2;
		}
	}";

	public static inline var TEST5:String = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:MultipleVariableDeclarations')
		function a() {
			var d; var e;
		}
	}";

	public static inline var TEST6:String = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:MultipleVariableDeclarations')
		function a() {
			var d,e,f;
		}
	}";
}