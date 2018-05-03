package misc;

import massive.munit.Assert;

import checkstyle.Main;

@:access(checkstyle)
class ConfigTest {

	@Test
	public function testExtendsConfigPath() {
		var main:Main = new Main();

		Assert.isNotNull(main.checker.checks);
		Assert.isTrue(main.checker.checks.length == 0);

		main.parseAndValidateConfig({
			extendsConfigPath: "checkstyle.json"
		});

		Assert.isNotNull(main.checker.checks);
		Assert.isTrue(main.checker.checks.length > 0);
	}
}