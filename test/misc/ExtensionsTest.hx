package misc;

import checks.CheckTestCase;
import checkstyle.checks.whitespace.IndentationCharacterCheck;

class ExtensionsTest extends CheckTestCase<ExtensionsTests> {
	@Test
	public function testExtensions() {
		assertNoMsg(new IndentationCharacterCheck(), TEST1);
	}
}

@:enum
abstract ExtensionsTests(String) to String {
	var TEST1 = "
	typedef TypedefName = {
		> OneTypedef,
		> OtherTypedef,
	}";
}