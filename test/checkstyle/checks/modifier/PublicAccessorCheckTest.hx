package checkstyle.checks.modifier;

class PublicAccessorCheckTest extends CheckTestCase<PublicAccessorCheckTests> {
	static inline var ERROR:String = "Accessor method should not be public";

	@Test
	public function testNonAccessors() {
		assertNoMsg(new PublicAccessorCheck(), NON_ACCESSOR);
	}

	@Test
	public function testPublicAccessors() {
		assertMsg(new PublicAccessorCheck(), PUBLIC_GETTER, ERROR);
		assertMsg(new PublicAccessorCheck(), PUBLIC_SETTER, ERROR);
		assertMsg(new PublicAccessorCheck(), IMPLICITLY_PUBLIC_GETTER, ERROR);
		assertMsg(new PublicAccessorCheck(), IMPLICITLY_PUBLIC_SETTER, ERROR);
		assertMsg(new PublicAccessorCheck(), INTERFACE_PUBLIC_GETTER, ERROR);
		assertMsg(new PublicAccessorCheck(), INTERFACE_PUBLIC_SETTER, ERROR);
	}
}

@:enum
abstract PublicAccessorCheckTests(String) to String {
	var NON_ACCESSOR = "
	abstractAndClass Test {
		public function _set_test() {}
		public function _get_test() {}
	}";
	var PUBLIC_GETTER = "
	abstractAndClass Test {
		public function get_test() {}
	}";
	var PUBLIC_SETTER = "
	abstractAndClass Test {
		override inline public function set_test() {}
	}";
	var IMPLICITLY_PUBLIC_GETTER = "
	@:publicFields class Test {
		function get_test() {}
	}";
	var IMPLICITLY_PUBLIC_SETTER = "
	@:publicFields class Test {
		function set_test() {}
	}";
	var INTERFACE_PUBLIC_GETTER = "
	interface ITest {
		function get_test() {}
	}";
	var INTERFACE_PUBLIC_SETTER = "
	interface ITest {
		function set_test() {}
	}";
}