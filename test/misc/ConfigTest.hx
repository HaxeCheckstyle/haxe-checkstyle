package misc;

import massive.munit.Assert;

import checkstyle.config.ConfigParser;

@:access(checkstyle)
class ConfigTest {

	@Test
	public function testExtendsConfigPath() {
		var configParser:ConfigParser = new ConfigParser(function (message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseAndValidateConfig(
			{
				extendsConfigPath: "checkstyle.json"
			},
			"./");

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length > 0);
	}
}