package checkstyle.checks.literal;

class ArrayLiteralCheckTest extends CheckTestCase<ArrayLiteralCheckTests> {
	@Test
	public function testWrongArrayInstantiation() {
		assertMsg(new ArrayLiteralCheck(), TEST1, 'Bad array instantiation, use the array literal notation "[]" which is shorter and cleaner');
	}

	@Test
	public function testCorrectArrayInstantiation() {
		assertNoMsg(new ArrayLiteralCheck(), TEST2);
	}
}

enum abstract ArrayLiteralCheckTests(String) to String {
	var TEST1 = "
	abstractAndClass Test {
		var _arr:Array<Int> = new Array<Int>();
	}";
	var TEST2 = "
	abstractAndClass Test {
		var _arr:Array<Int> = [];
	}";
}