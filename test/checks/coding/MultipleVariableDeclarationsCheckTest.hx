package checks.coding;

import checkstyle.checks.coding.MultipleVariableDeclarationsCheck;

class MultipleVariableDeclarationsCheckTest extends CheckTestCase<MultipleVariableDeclarationsCheckTests> {

	public function testMulitiVarsStatement() {
		assertMsg(new MultipleVariableDeclarationsCheck(), TEST1, 'Each variable declaration must be in its own statement');
		assertMsg(new MultipleVariableDeclarationsCheck(), TEST2, 'Each variable declaration must be in its own statement');
	}

	public function testMulitiVarsInOneLine() {
		assertMsg(new MultipleVariableDeclarationsCheck(), TEST3, 'Only one variable definition per line allowed');
	}

	public function testCorrectVariables() {
		assertNoMsg(new MultipleVariableDeclarationsCheck(), TEST4);
	}

	public function testSuppressWarnings() {
		assertNoMsg(new MultipleVariableDeclarationsCheck(), TEST5);
		assertNoMsg(new MultipleVariableDeclarationsCheck(), TEST6);
	}
}

@:enum
abstract MultipleVariableDeclarationsCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		function a() {
			var d,e = 2;
		}
	}";

	var TEST2 = "
	abstractAndClass Test {
		function a() {
			var d,e,f;
		}
	}";

	var TEST3 = "
	abstractAndClass Test {
		function a() {
			var d; var e;
		}
	}";

	var TEST4 = "
	abstractAndClass Test {
		function a() {
			var d;
			var e = 2;
		}
	}";

	var TEST5 = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:MultipleVariableDeclarations')
		function a() {
			var d; var e;
		}
	}";

	var TEST6 = "
	abstractAndClass Test {
		@SuppressWarnings('checkstyle:MultipleVariableDeclarations')
		function a() {
			var d,e,f;
		}
	}";
}