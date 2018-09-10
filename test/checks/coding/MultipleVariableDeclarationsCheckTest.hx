package checks.coding;

import checkstyle.checks.coding.MultipleVariableDeclarationsCheck;

class MultipleVariableDeclarationsCheckTest extends CheckTestCase<MultipleVariableDeclarationsCheckTests> {
	static inline var MSG_MULTI_VAR_COMMA:String = "Each variable declaration must be in its own statement";
	static inline var MSG_MULTI_VAR:String = "Only one variable definition per line allowed";

	@Test
	public function testMultiVarsStatement() {
		assertMsg(new MultipleVariableDeclarationsCheck(), TEST1, MSG_MULTI_VAR_COMMA);
		assertMsg(new MultipleVariableDeclarationsCheck(), TEST2, MSG_MULTI_VAR_COMMA);
	}

	@Test
	public function testMultiVarsInOneLine() {
		assertMsg(new MultipleVariableDeclarationsCheck(), TEST3, MSG_MULTI_VAR);
	}

	@Test
	public function testCorrectVariables() {
		assertNoMsg(new MultipleVariableDeclarationsCheck(), TEST4);
		assertNoMsg(new MultipleVariableDeclarationsCheck(), TEST5);
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
			var d = 10; var e;
			var d;var e;
			var f; var g;
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
		function foo() {
			var s = 'var f';
		}
	}";
}