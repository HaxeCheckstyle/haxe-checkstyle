package checkstyle.checks.type;

class AvoidIdentifierCheckTest extends CheckTestCase<AvoidIdentifierCheckTests> {
	@Test
	public function testCorrectTypeHints() {
		var check = new AvoidIdentifierCheck();
		assertNoMsg(check, TEST);

		check.avoidIdentifiers = ["TokenTree"];
		assertMsg(check, TEST, 'Identifier "TokenTree" should be avoided');
		check.avoidIdentifiers = ["a"];
		assertMsg(check, TEST, 'Identifier "a" should be avoided');

		check.avoidIdentifiers = ["TokenTree2"];
		assertNoMsg(check, TEST);
	}
}

enum abstract AvoidIdentifierCheckTests(String) to String {
	var TEST = "
	abstractAndClass Test {
		var a:Int;

		function checkIdent(ident:String, token:TokenTree) {
			if (isPosSuppressed(token.pos)) return;
			if (avoidIdentifiers.indexOf(ident) < 0) return;
			error(ident, token.pos);
		}

		@SuppressWarnings('checkstyle:AvoidIdentifier')
		function checkIdent2(ident:String, token:TokenTree2) {
			if (isPosSuppressed(token.pos)) return;
			if (avoidIdentifiers.indexOf(ident) < 0) return;
			error2(ident, token.pos);
		}
	}";
}