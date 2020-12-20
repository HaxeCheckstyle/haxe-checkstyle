package checkstyle.checks.meta;

class RedundantAllowMetaCheckTest extends CheckTestCase<RedundantAllowMetaCheckTests> {
	@Test
	public function testRedundantAccess() {
		var check = new RedundantAllowMetaCheck();
		assertNoMsg(check, CORRECT_ACCESS);
		assertMsg(check, REDUNDANT_ACCESS, 'Redundant "@:allow(pack.age.Test)" for field "test" detected');
		assertMsg(check, REDUNDANT_ACCESS_PACKAGE, 'Redundant "@:allow(pack.age.Test)" for field "test" detected');
		assertMsg(check, REDUNDANT_ACCESS_PUBLIC, 'Redundant "@:allow(pack.age.Test)" for public field "test" detected');
	}

	@Test
	public function testProhibitMeta() {
		var check = new RedundantAllowMetaCheck();
		check.prohibitMeta = true;
		assertMessages(check, CORRECT_ACCESS, [
			'Consider removing "@:allow(pack.age.Test)"',
			'Consider removing "@:allow(pack.age.Test2)"'
		]);
		assertMessages(check, REDUNDANT_ACCESS, [
			'Consider removing "@:allow(pack.age.Test)"',
			'Consider removing "@:allow(pack.age.Test)"'
		]);
		assertMessages(check, REDUNDANT_ACCESS_PACKAGE, [
			'Consider removing "@:allow(pack.age)"',
			'Consider removing "@:allow(pack.age.Test)"'
		]);
		assertMsg(check, REDUNDANT_ACCESS_PUBLIC, 'Consider removing "@:allow(pack.age.Test)"');

		check.prohibitMeta = false;
		assertNoMsg(check, CORRECT_ACCESS);
		assertMsg(check, REDUNDANT_ACCESS, 'Redundant "@:allow(pack.age.Test)" for field "test" detected');
		assertMsg(check, REDUNDANT_ACCESS_PACKAGE, 'Redundant "@:allow(pack.age.Test)" for field "test" detected');
		assertMsg(check, REDUNDANT_ACCESS_PUBLIC, 'Redundant "@:allow(pack.age.Test)" for public field "test" detected');
	}
}

enum abstract RedundantAllowMetaCheckTests(String) to String {
	var CORRECT_ACCESS = "
	@:allow(pack.age.Test)
	abstractAndClass Test {

		@:allow(pack.age.Test2)
		function test() {}
	}

	abstractAndClass Test2 {

		@:access(pack.age.Test2)
		function test() {}
	}";
	var REDUNDANT_ACCESS = "
	@:allow(pack.age.Test)
	abstractAndClass Test {

		@:allow(pack.age.Test)
		function test() {}
	}";
	var REDUNDANT_ACCESS_PACKAGE = "
	@:allow(pack.age)
	abstractAndClass Test {

		@:allow(pack.age.Test)
		function test() {}
	}";
	var REDUNDANT_ACCESS_PUBLIC = "
	abstractAndClass Test {

		@:allow(pack.age.Test)
		public function test() {}
	}";
}