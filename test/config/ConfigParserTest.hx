package config;

import checkstyle.config.Config;
import checkstyle.config.ConfigParser;
import checkstyle.utils.ConfigUtils;

class ConfigParserTest {
	static inline var LOCAL_PATH:String = "./";

	@Test
	public function testCheckstyleConfig() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
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
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseAndValidateConfig({
			extendsConfigPath: "checkstyle.json"
		}, LOCAL_PATH);

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length > 0);
	}

	@Test
	public function testValidateParserThread() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 0}, "");
		Assert.areEqual(5, configParser.numberOfCheckerThreads);
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 10}, "");
		Assert.areEqual(10, configParser.numberOfCheckerThreads);
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 50}, "");
		Assert.areEqual(15, configParser.numberOfCheckerThreads);

		configParser.overrideCheckerThreads = 13;
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 14}, "");
		Assert.areEqual(13, configParser.numberOfCheckerThreads);

		configParser.overrideCheckerThreads = 18;
		configParser.parseAndValidateConfig({numberOfCheckerThreads: 14}, "");
		Assert.areEqual(15, configParser.numberOfCheckerThreads);
	}

	@Test
	public function testCheckCount() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.areEqual(72, configParser.getCheckCount());
	}

	@Test
	public function testUnusedChecks() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.areEqual(0, configParser.getUsedCheckCount());
		configParser.addAllChecks();
		Assert.areEqual(72, configParser.getUsedCheckCount());
	}

	@Test
	public function testConfig() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		configParser.addAllChecks();
		var config:Config = ConfigUtils.makeConfigFromChecker(configParser.checker);
		config.numberOfCheckerThreads = 11;

		configParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});
		configParser.parseAndValidateConfig(config, "");
		Assert.areEqual(configParser.getCheckCount(), configParser.getUsedCheckCount());
		Assert.areEqual(11, configParser.numberOfCheckerThreads);
	}

	@Test
	public function testConfigVersion1() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseAndValidateConfig({
			version: 1
		}, LOCAL_PATH);

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);
	}

	@Test
	public function testConfigWrongVersion() {
		var failMessage:String = "";
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			failMessage = message;
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseAndValidateConfig({
			version: 0
		}, LOCAL_PATH);

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);
		Assert.areEqual("configuration file has unknown version: 0", failMessage);
	}

	@Test
	public function testExcludeConfigVersion1() {
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			Assert.fail(message);
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseExcludes({
			version: 1
		});
	}

	@Test
	public function testExcludeConfigWrongVersion() {
		var failMessage:String = "";
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			failMessage = message;
		});

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		configParser.parseExcludes({
			version: 0
		});

		Assert.areEqual("exclude configuration file has unknown version: 0", failMessage);
	}

	@Test
	public function testValidateMode() {
		var failMessage:String = "";
		var configParser:ConfigParser = new ConfigParser(function(message:String) {
			failMessage = message;
		});
		configParser.validateMode = RELAXED;

		Assert.isNotNull(configParser.checker.checks);
		Assert.isTrue(configParser.checker.checks.length == 0);

		var config:Config = {
			version: 0,
			checks: [
				{
					"type": "non existing check name"
				},
				{
					"type": "Trace",
					"props": {
						"non_existing_property": 100
					}
				}
			]
		};
		configParser.parseAndValidateConfig(config, LOCAL_PATH);

		Assert.areEqual("", failMessage);

		configParser.validateMode = STRICT;
		configParser.parseAndValidateConfig(config, LOCAL_PATH);
		Assert.areEqual("Check Trace has no property named 'non_existing_property'", failMessage);
	}
}