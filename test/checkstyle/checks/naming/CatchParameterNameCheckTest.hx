package checkstyle.checks.naming;

class CatchParameterNameCheckTest extends CheckTestCase<CatchParameterNameCheckTests> {
	@Test
	public function testCorrectNaming() {
		var check = new CatchParameterNameCheck();
		assertNoMsg(check, TEST1);
	}

	@Test
	public function testInCorrectNaming() {
		var check = new CatchParameterNameCheck();
		assertMsg(check, TEST2, '"Val" must match pattern "~/${check.format}/"');
	}

	@Test
	public function testCustomNaming() {
		var check = new CatchParameterNameCheck();
		check.format = "^(ex)$";
		assertMsg(check, TEST1, '"e" must match pattern "~/${check.format}/"');
	}
}

enum abstract CatchParameterNameCheckTests(String) to String {
	var TEST1 = "
	class Test {
		public function test() {
			try {
				var Count:Int = 1;
			}
			catch(e:String) {}
		}
	}";
	var TEST2 = "
	class Test {
		public function test() {
			try {
				var Count:Int = 1;
			}
			catch(Val:String) {}
		}
	}";
}