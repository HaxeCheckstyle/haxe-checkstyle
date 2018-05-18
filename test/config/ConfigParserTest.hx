package config;

import massive.munit.Assert;

import checkstyle.config.ConfigParser;

class ConfigParserTest {

	@Test
	public function testCheckstyleConfig() {
		var configParser:ConfigParser = new ConfigParser(function (message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.loadConfig("checkstyle.json");

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length > 0);
		Assert.isTrue(configParser.checker.checks.length != configParser.getCheckCount());
	}

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
	public function testValidateParserThread() {
		var configParser:ConfigParser = new ConfigParser(function (message:String) {
			Assert.fail(message);
		});
		configParser.parseAndValidateConfig({ numberOfCheckerThreads: 0 }, "");
		Assert.areEqual(5, configParser.numberOfCheckerThreads);
		configParser.parseAndValidateConfig({ numberOfCheckerThreads: 10 }, "");
		Assert.areEqual(10, configParser.numberOfCheckerThreads);
		configParser.parseAndValidateConfig({ numberOfCheckerThreads: 50 }, "");
		Assert.areEqual(15, configParser.numberOfCheckerThreads);

		configParser.overrideCheckerThreads = 13;
		configParser.parseAndValidateConfig({ numberOfCheckerThreads: 14 }, "");
		Assert.areEqual(13, configParser.numberOfCheckerThreads);

		configParser.overrideCheckerThreads = 18;
		configParser.parseAndValidateConfig({ numberOfCheckerThreads: 14 }, "");
		Assert.areEqual(15, configParser.numberOfCheckerThreads);
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