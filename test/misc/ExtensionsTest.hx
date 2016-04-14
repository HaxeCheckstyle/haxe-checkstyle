package misc;

import checks.CheckTestCase;
import checkstyle.checks.whitespace.IndentationCharacterCheck;

class ExtensionsTest extends CheckTestCase<ExtensionsTests> {

	public function testExtensions() {
		try {
			assertNoMsg(new IndentationCharacterCheck(), TEST1);
			// unless haxeparse bug is fixed, this code is unreachable
			assertFalse(true);
		}
		catch (e:Dynamic) {
			assertEquals("misc.ExtensionsTest", e.classname);
			assertEquals("expected '' but was 'Parsing failed: Unexpected >", e.error.substr(0, 49));
		}
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