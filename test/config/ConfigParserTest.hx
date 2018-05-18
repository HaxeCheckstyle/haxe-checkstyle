package config;

import massive.munit.Assert;

import checkstyle.config.ConfigParser;

class ConfigParserTest {

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

	@Test
	public function testCheckCount() {
		var configParser:ConfigParser = new ConfigParser(function (message:String) {
			Assert.fail(message);
		});

		Assert.areEqual(66, configParser.getCheckCount());
	}

	@Test
	public function testUnusedChecks() {
		var configParser:ConfigParser = new ConfigParser(function (message:String) {
			Assert.fail(message);
		});

		Assert.areEqual(0, configParser.getUsedCheckCount());
		configParser.addAllChecks();
		Assert.areEqual(66, configParser.getUsedCheckCount());
	}
}