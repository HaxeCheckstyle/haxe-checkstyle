package misc;

import checks.CheckTestCase;
#if (haxeparser >= "3.3.0")
import checkstyle.checks.whitespace.IndentationCharacterCheck;
#end

class ExtensionsTest extends CheckTestCase<ExtensionsTests> {

	@Test
	public function testExtensions() {
		#if (haxeparser >= "3.3.0")
		assertNoMsg(new IndentationCharacterCheck(), TEST1);
		#else
		assertTrue(true);
		#end
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