package checks.meta;

import checkstyle.checks.meta.RedundantAccessMetaCheck;

class RedundantAccessMetaCheckTest extends CheckTestCase<RedundantAccessMetaCheckTests> {
	@Test
	public function testRedundantAccess() {
		var check = new RedundantAccessMetaCheck();
		assertNoMsg(check, CORRECT_ACCESS);
		assertMsg(check, REDUNDANT_ACCESS, 'Redundant "@:access(pack.age.Test)" for field "test" detected');
		assertMsg(check, REDUNDANT_ACCESS_PACKAGE, 'Redundant "@:access(pack.age.Test)" for field "test" detected');
	}

	@Test
	public function testProhibitMeta() {
		var check = new RedundantAccessMetaCheck();
		check.prohibitMeta = true;
		assertMsg(check, CORRECT_ACCESS, 'Consider removing "@:access(pack.age.Test2)"');
		assertMsg(check, REDUNDANT_ACCESS, 'Consider removing "@:access(pack.age.Test)"');
		assertMsg(check, REDUNDANT_ACCESS_PACKAGE, 'Consider removing "@:access(pack.age.Test)"');

		check.prohibitMeta = false;
		assertNoMsg(check, CORRECT_ACCESS);
		assertMsg(check, REDUNDANT_ACCESS, 'Redundant "@:access(pack.age.Test)" for field "test" detected');
		assertMsg(check, REDUNDANT_ACCESS_PACKAGE, 'Redundant "@:access(pack.age.Test)" for field "test" detected');
	}
}

@:enum
abstract RedundantAccessMetaCheckTests(String) to String {
	var CORRECT_ACCESS = "
	@:access(pack.age.Test)
	abstractAndClass Test {

		@:access(pack.age.Test2)
		function test() {}
	}

	abstractAndClass Test2 {

		@:access(pack.age.Test2)
		function test() {}
	}";
	var REDUNDANT_ACCESS = "
	@:access(pack.age.Test)
	abstractAndClass Test {

		@:access(pack.age.Test)
		function test() {}
	}";
	var REDUNDANT_ACCESS_PACKAGE = "
	@:access(pack.age)
	abstractAndClass Test {

		@:access(pack.age.Test)
		function test() {}
	}";
}